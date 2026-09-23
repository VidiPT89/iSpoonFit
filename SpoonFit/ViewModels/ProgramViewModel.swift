import Foundation
import SwiftData

/// Owns the persisted program state and the completed-session log, and derives
/// everything the screens need from them: which day is next, how far along the
/// program is, and which achievements have been earned.
@MainActor
@Observable
final class ProgramViewModel {
    private(set) var state: ProgramState?
    private(set) var sessions: [CompletedSession] = []

    private(set) var context: ModelContext?
    /// Nil for a local-only session (tests, or a debug build without Firebase).
    private(set) var sync: CloudSyncing?
    private let calendar = Calendar.current

    /// Reset every calendar day, so "low-energy" never silently carries over.
    var lowEnergyToday: Bool {
        didSet { persistLowEnergy() }
    }

    init() {
        let storedDay = UserDefaults.standard.object(forKey: Self.lowEnergyDayKey) as? Date
        let isToday = storedDay.map { Calendar.current.isDateInToday($0) } ?? false
        lowEnergyToday = isToday && UserDefaults.standard.bool(forKey: Self.lowEnergyKey)
    }

    private static let lowEnergyKey = "lowEnergyToday"
    private static let lowEnergyDayKey = "lowEnergyTodayDate"

    private func persistLowEnergy() {
        UserDefaults.standard.set(lowEnergyToday, forKey: Self.lowEnergyKey)
        UserDefaults.standard.set(Date(), forKey: Self.lowEnergyDayKey)
    }

    // MARK: - Loading

    func load(context: ModelContext, sync: CloudSyncing? = nil) {
        self.context = context
        self.sync = sync
        refresh()
    }

    func refresh() {
        guard let context else { return }
        state = (try? context.fetch(FetchDescriptor<ProgramState>()))?.first
        let descriptor = FetchDescriptor<CompletedSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        sessions = (try? context.fetch(descriptor)) ?? []
    }

    var hasOnboarded: Bool { state != nil }

    func startProgram(startDate: Date, reminderTime: Date?, medicalClearance: Bool) {
        guard let context else { return }
        let newState = ProgramState(
            startDate: startDate,
            reminderTime: reminderTime,
            reminderEnabled: reminderTime != nil,
            medicalClearance: medicalClearance
        )
        context.insert(newState)
        try? context.save()
        refresh()
        pushState()
        if let reminderTime {
            Task { await updateReminder(enabled: true, time: reminderTime) }
        }
    }

    /// Saves the reminder preference and schedules or cancels the
    /// notifications. Returns false when iOS refused permission, in which case
    /// the preference is stored as off.
    @discardableResult
    func updateReminder(enabled: Bool, time: Date) async -> Bool {
        let granted = enabled ? await ReminderManager.schedule(at: time) : true
        if !enabled { ReminderManager.cancelAll() }
        guard let state, let context else { return granted }
        state.reminderEnabled = enabled && granted
        state.reminderTime = time
        state.updatedAt = .now
        try? context.save()
        pushState()
        return granted
    }

    /// Reminders are scheduled on the device, so they are set up again after
    /// signing in on a new phone, and after a language change, since their
    /// text is fixed when scheduled.
    func rescheduleReminderIfNeeded() {
        guard let state, state.reminderEnabled, let time = state.reminderTime else { return }
        Task { await ReminderManager.schedule(at: time) }
    }

    func updateStartDate(_ date: Date) {
        guard let state, let context else { return }
        state.startDate = calendar.startOfDay(for: date)
        state.updatedAt = .now
        try? context.save()
        refresh()
        pushState()
    }

    // MARK: - Progress

    var completedDayIndices: Set<Int> { Set(sessions.map(\.dayIndex)) }

    var completedCount: Int { completedDayIndices.count }

    var progress: Double { Double(completedCount) / Double(ProgramData.totalDays) }

    var isProgramComplete: Bool { completedCount >= ProgramData.totalDays }

    /// The first day still to be done. Missing a day never blocks the program:
    /// the next available workout is simply the first unfinished one.
    var nextDayIndex: Int? {
        (1...ProgramData.totalDays).first { !completedDayIndices.contains($0) }
    }

    var nextDay: ProgramDay? { nextDayIndex.flatMap(ProgramData.day(at:)) }

    /// A day can be started once every earlier day is done.
    func isUnlocked(_ day: ProgramDay) -> Bool {
        guard day.index > 1 else { return true }
        return completedDayIndices.contains(day.index - 1) || completedDayIndices.contains(day.index)
    }

    func isCompleted(_ day: ProgramDay) -> Bool { completedDayIndices.contains(day.index) }

    /// Done, but only ever in low-energy mode: the calendar marks it with a leaf.
    func isCompletedOnlyOnLowEnergy(_ day: ProgramDay) -> Bool {
        let runs = sessions.filter { $0.dayIndex == day.index }
        return !runs.isEmpty && runs.allSatisfy(\.lowEnergy)
    }

    func completedDays(inWeek week: Int) -> Int {
        ProgramData.days(inWeek: week).filter { isCompleted($0) }.count
    }

    func isWeekComplete(_ week: Int) -> Bool {
        completedDays(inWeek: week) == ProgramData.daysPerWeek
    }

    var weeksCompleted: Int {
        (1...ProgramData.totalWeeks).filter { isWeekComplete($0) }.count
    }

    var totalMinutes: Int {
        Int((Double(sessions.reduce(0) { $0 + $1.durationSeconds }) / 60).rounded())
    }

    // MARK: - Calendar

    /// Whole days left before the chosen start date; zero once it has come.
    var daysUntilStart: Int {
        guard let start = state?.startDate else { return 0 }
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: start)).day ?? 0
        return max(0, days)
    }

    /// One workout a day is the plan; after that Today suggests resting.
    var hasTrainedToday: Bool {
        sessions.contains { calendar.isDateInToday($0.date) }
    }

    /// Friday, Saturday and Sunday are rest days.
    var isRestDayToday: Bool {
        let weekday = calendar.component(.weekday, from: Date())
        return weekday == 6 || weekday == 7 || weekday == 1
    }

    /// Days until the next Monday to Thursday slot, for the rest-day card.
    var daysUntilNextTrainingDay: Int {
        let weekday = calendar.component(.weekday, from: Date())
        switch weekday {
        case 6: return 3   // Friday
        case 7: return 2   // Saturday
        case 1: return 1   // Sunday
        default: return 0
        }
    }

    // MARK: - Mutations

    func complete(
        day: ProgramDay,
        durationSeconds: Int,
        lowEnergy: Bool,
        energy: Int? = nil,
        discomfort: Int? = nil,
        note: String? = nil
    ) {
        guard let context else { return }
        let session = CompletedSession(
            dayIndex: day.index,
            durationSeconds: durationSeconds,
            lowEnergy: lowEnergy,
            energy: energy,
            discomfort: discomfort,
            note: note?.isEmpty == true ? nil : note
        )
        context.insert(session)
        try? context.save()
        lowEnergyToday = false
        refresh()
        push(session)
    }

    func delete(_ session: CompletedSession) {
        guard let context else { return }
        let id = session.uuid
        context.delete(session)
        try? context.save()
        refresh()
        removeRemoteSessions([id])
    }

    func restartProgram() {
        guard let context else { return }
        let ids = sessions.map(\.uuid)
        for session in sessions {
            context.delete(session)
        }
        state?.startDate = ProgramState.nextMonday()
        state?.updatedAt = .now
        try? context.save()
        lowEnergyToday = false
        refresh()
        removeRemoteSessions(ids)
        pushState()
    }

    /// Clears what this device keeps outside the account's store, so the
    /// next person to sign in on it starts clean.
    static func clearDeviceState() {
        UserDefaults.standard.removeObject(forKey: lowEnergyKey)
        UserDefaults.standard.removeObject(forKey: lowEnergyDayKey)
        ReminderManager.cancelAll()
    }

    // MARK: - Achievements

    func isUnlocked(_ achievement: Achievement) -> Bool {
        achievement.isUnlocked(in: self)
    }
}

enum Achievement: String, CaseIterable, Identifiable {
    case firstWorkout, firstWeek, halfway, firstLoad, finalChallenge

    var id: String { rawValue }
    var titleKey: String { "achievement.\(rawValue)" }

    var icon: String {
        switch self {
        case .firstWorkout: return "sparkles"
        case .firstWeek: return "calendar.badge.checkmark"
        case .halfway: return "flag.checkered"
        case .firstLoad: return "dumbbell.fill"
        case .finalChallenge: return "trophy.fill"
        }
    }

    @MainActor
    func isUnlocked(in viewModel: ProgramViewModel) -> Bool {
        let done = viewModel.completedDayIndices
        switch self {
        case .firstWorkout: return !done.isEmpty
        case .firstWeek: return viewModel.isWeekComplete(1)
        case .halfway: return done.contains(14)
        case .firstLoad: return done.contains(13)
        case .finalChallenge: return done.contains(28)
        }
    }
}
