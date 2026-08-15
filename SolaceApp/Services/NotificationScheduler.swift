import Foundation
import UserNotifications

/// Schedules the local, on-device daily check-in reminder. This is
/// intentionally local-only (`UNUserNotificationCenter`, not remote
/// push/APNs) — there's no server component in this app to trigger a
/// remote notification from, and a local reminder behaves identically to
/// the user on their own device.
// UNUserNotificationCenter is documented as thread-safe but the type doesn't
// carry Sendable conformance itself, hence @unchecked here — same rationale
// as the FirestoreXService classes.
final class NotificationScheduler: @unchecked Sendable {
    static let reminderIdentifier = "daily-check-in-reminder"

    func requestAuthorization() async -> Bool {
        let granted = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Time for a check-in"
        content.body = "Take a moment for your mood or a gratitude note."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: Self.reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
    }
}
