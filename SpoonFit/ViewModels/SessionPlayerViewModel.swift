import Foundation

/// Drives one guided workout. The countdown is anchored to a `Date` rather
/// than counted in ticks, so locking the screen or switching apps never makes
/// the session drift.
@MainActor
@Observable
final class SessionPlayerViewModel {
    let day: ProgramDay

    private(set) var steps: [SessionStep]
    private(set) var index: Int = 0
    private(set) var remaining: Int
    private(set) var isPaused = false
    private(set) var isFinished = false
    private(set) var lowEnergy: Bool
    private(set) var showsSwitchSideBanner = false

    private var stepEndDate: Date?
    private var ticker: Task<Void, Never>?
    private var startedAt = Date()
    private var pausedAt: Date?
    private var pausedTotal: TimeInterval = 0
    private var announcedSwitchSide = false

    init(day: ProgramDay, lowEnergy: Bool) {
        self.day = day
        self.lowEnergy = lowEnergy
        let built = SessionBuilder.steps(for: day, lowEnergy: lowEnergy)
        self.steps = built
        self.remaining = built.first?.seconds ?? 0
    }

    // MARK: - Derived state

    var currentStep: SessionStep {
        steps[min(index, steps.count - 1)]
    }

    var nextStep: SessionStep? {
        let next = index + 1
        return next < steps.count ? steps[next] : nil
    }

    /// The exercise the user should be looking at: on a rest or get-ready step
    /// that is the one coming up.
    var displayedRef: ExerciseRef { currentStep.ref }

    var totalSeconds: Int { steps.reduce(0) { $0 + $1.seconds } }

    var elapsedSeconds: Int {
        let before = steps.prefix(index).reduce(0) { $0 + $1.seconds }
        return before + max(0, currentStep.seconds - remaining)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(1, Double(elapsedSeconds) / Double(totalSeconds))
    }

    /// 1 → 0 across the current step, for the countdown ring.
    var stepProgress: Double {
        guard currentStep.seconds > 0 else { return 0 }
        return Double(remaining) / Double(currentStep.seconds)
    }

    var formattedRemaining: String {
        remaining >= 60
            ? String(format: "%d:%02d", remaining / 60, remaining % 60)
            : String(remaining)
    }

    /// One entry per work interval, used by the segmented bar at the bottom.
    var workStepIndices: [Int] {
        steps.indices.filter { steps[$0].isWork }
    }

    // MARK: - Lifecycle

    func start() {
        SessionAudio.shared.activate()
        startedAt = Date()
        pausedTotal = 0
        beginStep()
        startTicker()
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        SessionAudio.shared.deactivate()
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                self?.tick()
            }
        }
    }

    private func beginStep() {
        let step = currentStep
        remaining = step.seconds
        stepEndDate = Date().addingTimeInterval(TimeInterval(step.seconds))
        announcedSwitchSide = false
        showsSwitchSideBanner = false
        announceStepStart(step)
    }

    private func announceStepStart(_ step: SessionStep) {
        switch step.kind {
        case .getReady:
            SessionAudio.shared.play(.countdownTick)
            SessionAudio.shared.speak(key: "session.getReady")
            Haptics.impact(.light)
        case .work:
            SessionAudio.shared.play(.workStart)
            SessionAudio.shared.speak(t(step.ref.catalogEntry.nameKey))
            Haptics.impact(.medium)
        case .rest:
            SessionAudio.shared.play(.restStart)
            SessionAudio.shared.speak(key: "session.rest")
            Haptics.impact(.light)
        }
    }

    // MARK: - Ticking

    private func tick() {
        guard !isPaused, !isFinished, let end = stepEndDate else { return }
        let secondsLeft = end.timeIntervalSinceNow
        let newRemaining = max(0, Int(secondsLeft.rounded(.up)))

        if newRemaining != remaining {
            remaining = newRemaining
            handleCountdown(newRemaining)
            handleSwitchSide(newRemaining)
        }

        if secondsLeft <= 0 {
            advance()
        }
    }

    private func handleCountdown(_ value: Int) {
        guard (1...3).contains(value) else { return }
        SessionAudio.shared.play(.countdownTick)
        Haptics.impact(.rigid)
        SessionAudio.shared.speak(Self.spelled(value))
    }

    private func handleSwitchSide(_ value: Int) {
        guard !announcedSwitchSide,
              let switchAt = currentStep.switchSideAtSecond,
              value <= switchAt else { return }
        announcedSwitchSide = true
        showsSwitchSideBanner = true
        SessionAudio.shared.play(.switchSide)
        SessionAudio.shared.speak(key: "session.switchSide")
        Haptics.warning()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            self?.showsSwitchSideBanner = false
        }
    }

    private static func spelled(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = LocalizationManager.shared.current.locale
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    // MARK: - Navigation

    private func advance() {
        if index + 1 < steps.count {
            index += 1
            beginStep()
        } else {
            finish()
        }
    }

    func skipForward() {
        Haptics.selection()
        advance()
    }

    func skipBackward() {
        Haptics.selection()
        guard index > 0 else {
            beginStep()
            return
        }
        index -= 1
        beginStep()
    }

    func togglePause() {
        isPaused.toggle()
        Haptics.selection()
        if isPaused {
            pausedAt = Date()
            SessionAudio.shared.stopSpeaking()
        } else if let pausedAt {
            pausedTotal += Date().timeIntervalSince(pausedAt)
            self.pausedAt = nil
            stepEndDate = Date().addingTimeInterval(TimeInterval(remaining))
        }
    }

    func pauseIfRunning() {
        guard !isPaused, !isFinished else { return }
        togglePause()
    }

    /// Rebuilds the remaining session with the easier parameters and resumes
    /// from the start of the current round.
    func switchToLowEnergy() {
        guard !lowEnergy else { return }
        let block = currentStep.block
        let round = currentStep.round
        lowEnergy = true
        steps = SessionBuilder.steps(for: day, lowEnergy: true)

        let maxRounds = steps.map(\.totalRounds).max() ?? 1
        let targetRound = min(round, maxRounds)
        let target = steps.firstIndex {
            $0.block == block && $0.round == targetRound && $0.isWork
        } ?? 0
        index = min(target, steps.count - 1)
        if isPaused { togglePause() }
        beginStep()
    }

    private func finish() {
        guard !isFinished else { return }
        isFinished = true
        stepEndDate = nil
        ticker?.cancel()
        SessionAudio.shared.play(.finished)
        SessionAudio.shared.speak(key: "session.done")
        Haptics.success()
    }

    /// Wall-clock time spent in the session, ignoring time spent paused.
    var completedDurationSeconds: Int {
        let paused = pausedTotal + (pausedAt.map { Date().timeIntervalSince($0) } ?? 0)
        return max(0, Int(Date().timeIntervalSince(startedAt) - paused))
    }
}
