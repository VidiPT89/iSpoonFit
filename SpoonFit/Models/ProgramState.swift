import Foundation
import SwiftData

/// The single row that records when the program started and how the user
/// wants to be reminded. Its existence is also what marks onboarding as done.
@Model
final class ProgramState {
    var startDate: Date
    var reminderTime: Date?
    var reminderEnabled: Bool
    var medicalClearance: Bool

    init(startDate: Date, reminderTime: Date? = nil, reminderEnabled: Bool = false, medicalClearance: Bool = false) {
        self.startDate = startDate
        self.reminderTime = reminderTime
        self.reminderEnabled = reminderEnabled
        self.medicalClearance = medicalClearance
    }

    /// The Monday on or after `date`, which is where a program always starts.
    static func nextMonday(after date: Date = Date(), calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: start)
        // Calendar weekday is 1 = Sunday ... 7 = Saturday.
        let daysUntilMonday = (9 - weekday) % 7
        let offset = daysUntilMonday == 0 ? 7 : daysUntilMonday
        return calendar.date(byAdding: .day, value: offset, to: start) ?? start
    }
}
