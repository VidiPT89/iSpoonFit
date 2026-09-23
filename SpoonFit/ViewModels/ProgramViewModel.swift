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

    private var context: ModelContext?
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

    func load(context: ModelContext) {
        self.context = context
        refresh()
    }

    private func refresh() {
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
        if let reminderTime {
            Task { await ReminderManager.schedule(at: reminderTime) }
        }
    }

    func updateReminder(enabled: Bool, time: Date) {
        guard let state, let context else { return }
        state.reminderEnabled = enabled
        state.reminderTime = time
        try? context.save()
        Task {
            if enabled {
                await ReminderManager.schedule(at: time)
            } else {
                ReminderManager.cancelAll()
            }
        }
    }

    func updateStartDate(_ date: Date) {
        guard let state, let context else { return }
        state.startDate = calendar.startOfDay(for: date)
        try? context.save()
        refresh()
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
    }

    func delete(_ session: CompletedSession) {
        guard let context else { return }
        context.delete(session)
        try? context.save()
        refresh()
    }

    func restartProgram() {
        guard let context else { return }
        for session in sessions {
            context.delete(session)
        }
        state?.startDate = ProgramState.nextMonday()
        try? context.save()
        lowEnergyToday = false
        refresh()
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
