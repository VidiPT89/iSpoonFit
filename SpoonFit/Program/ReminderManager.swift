import Foundation
import UserNotifications

/// Local-only workout reminders on training days. Nothing leaves the device:
/// these are scheduled by iOS and delivered by iOS.
enum ReminderManager {
    /// Calendar weekday numbers for Monday through Thursday.
    private static let trainingWeekdays = [2, 3, 4, 5]
    private static let identifierPrefix = "spoonfit.reminder."

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func cancelAll() {
        let identifiers = trainingWeekdays.map { identifierPrefix + String($0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Replaces any pending reminders. Returns false when the user has not
    /// allowed notifications, so the caller can switch the setting back off.
    @discardableResult
    static func schedule(at time: Date, calendar: Calendar = .current) async -> Bool {
        cancelAll()
        guard await requestAuthorization() else { return false }

        let components = calendar.dateComponents([.hour, .minute], from: time)
        let content = UNMutableNotificationContent()
        content.title = t("reminder.title")
        content.body = t("reminder.body")
        content.sound = .default

        let center = UNUserNotificationCenter.current()
        for weekday in trainingWeekdays {
            var trigger = DateComponents()
            trigger.weekday = weekday
            trigger.hour = components.hour
            trigger.minute = components.minute

            let request = UNNotificationRequest(
                identifier: identifierPrefix + String(weekday),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            )
            try? await center.add(request)
        }
        return true
    }
}
