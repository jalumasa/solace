import SwiftUI

/// Local, on-device daily check-in reminder settings — see
/// `NotificationScheduler` for why this is local rather than remote push.
struct ReminderSettingsSection: View {
    @AppStorage("reminderEnabled") private var isEnabled = false
    @AppStorage("reminderMinutesSinceMidnight") private var minutesSinceMidnight = 19 * 60

    private let scheduler = NotificationScheduler()

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: minutesSinceMidnight / 60,
                    minute: minutesSinceMidnight % 60,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                let hour = components.hour ?? 19
                let minute = components.minute ?? 0
                minutesSinceMidnight = hour * 60 + minute
                if isEnabled {
                    scheduler.scheduleDailyReminder(hour: hour, minute: minute)
                }
            }
        )
    }

    var body: some View {
        Section("Reminders") {
            Toggle("Daily check-in reminder", isOn: Binding(
                get: { isEnabled },
                set: { newValue in setEnabled(newValue) }
            ))

            if isEnabled {
                DatePicker("Reminder time", selection: reminderTime, displayedComponents: .hourAndMinute)
            }
        }
    }

    private func setEnabled(_ newValue: Bool) {
        isEnabled = newValue
        if newValue {
            Task {
                let granted = await scheduler.requestAuthorization()
                if granted {
                    scheduler.scheduleDailyReminder(hour: minutesSinceMidnight / 60, minute: minutesSinceMidnight % 60)
                } else {
                    isEnabled = false
                }
            }
        } else {
            scheduler.cancelReminder()
        }
    }
}
