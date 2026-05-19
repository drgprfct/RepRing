import Foundation
@preconcurrency import UserNotifications
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    @Published var statusMessage = "Reminders are optional."
    @Published private(set) var scheduledReminderCount = 0
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    nonisolated private static let legacyDailyReminderID = "RepRing.dailyReminder"
    nonisolated private static let dailyReminderPrefix = "RepRing.dailyReminder."

    func refreshSettings() {
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            authorizationStatus = settings.authorizationStatus
            refreshPendingRequests()

            if settings.authorizationStatus == .denied {
                statusMessage = "Notifications are off. Enable them in Settings to get the nudges."
            }
        }
    }

    func refreshPendingRequests() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let count = requests.filter { request in
                request.identifier == Self.legacyDailyReminderID ||
                request.identifier.hasPrefix(Self.dailyReminderPrefix)
            }.count

            Task { @MainActor in
                self.scheduledReminderCount = count
            }
        }
    }

    func reminderCounterText(configuredCount: Int) -> String {
        if scheduledReminderCount > 0 {
            if scheduledReminderCount == configuredCount || configuredCount == 0 {
                return scheduledReminderCount == 1 ? "1 reminder scheduled" : "\(scheduledReminderCount) reminders scheduled"
            }
            return "\(scheduledReminderCount) scheduled • \(configuredCount) active"
        }

        if configuredCount > 0 {
            return configuredCount == 1 ? "1 reminder ready" : "\(configuredCount) reminders ready"
        }

        return "No reminders set"
    }

    func requestAuthorizationAndSchedule(reminders: [ReminderItem], crunchGoal: Int, pushGoal: Int) {
        Task { @MainActor in
            do {
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

                guard granted else {
                    authorizationStatus = .denied
                    statusMessage = "Notifications were not allowed."
                    refreshPendingRequests()
                    return
                }

                let settings = await center.notificationSettings()
                authorizationStatus = settings.authorizationStatus
                scheduleDailyReminders(reminders: reminders,
                                       crunchGoal: crunchGoal,
                                       pushGoal: pushGoal)
            } catch {
                statusMessage = "Reminder permission error: \(error.localizedDescription)"
                refreshPendingRequests()
            }
        }
    }

    func scheduleDailyReminders(reminders: [ReminderItem], crunchGoal: Int, pushGoal: Int) {
        Task { @MainActor in
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            authorizationStatus = settings.authorizationStatus
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                performScheduling(center: center,
                                  reminders: reminders,
                                  crunchGoal: crunchGoal,
                                  pushGoal: pushGoal)
            case .denied:
                statusMessage = "Notifications are off. Enable them in Settings to get the nudges."
                refreshPendingRequests()
            case .notDetermined:
                statusMessage = "Tap Save reminders to request notification permission."
                refreshPendingRequests()
            @unknown default:
                statusMessage = "Notification status is unknown."
                refreshPendingRequests()
            }
        }
    }

    private func performScheduling(center: UNUserNotificationCenter,
                                   reminders: [ReminderItem],
                                   crunchGoal: Int,
                                   pushGoal: Int) {
        let activeReminders = reminders
            .filter(\.isEnabled)
            .sorted { lhs, rhs in minutesSinceMidnight(lhs.time) < minutesSinceMidnight(rhs.time) }

        removeExistingReminderRequests(center: center) {
            guard !activeReminders.isEmpty else {
                Task { @MainActor in
                    self.scheduledReminderCount = 0
                    self.statusMessage = "All reminders are off."
                    self.refreshPendingRequests()
                }
                return
            }

            let group = DispatchGroup()
            let failureLock = NSLock()
            var failureMessages: [String] = []

            for (index, reminder) in activeReminders.enumerated() {
                let content = UNMutableNotificationContent()
                content.title = "RepRing check-in"
                content.subtitle = activeReminders.count > 1 ? "Reminder \(index + 1) of \(activeReminders.count)" : ""
                content.body = "Count your reps. Today’s board: \(crunchGoal) crunches and \(pushGoal) push-ups."
                content.sound = .default
                content.threadIdentifier = "RepRing.dailyReminders"
                content.userInfo = [
                    "RepRingReminderID": reminder.id.uuidString,
                    "RepRingReminderIndex": index + 1
                ]

                var components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
                components.second = 0

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: Self.dailyReminderPrefix + reminder.id.uuidString,
                                                    content: content,
                                                    trigger: trigger)

                group.enter()
                center.add(request) { error in
                    if let error {
                        failureLock.lock()
                        failureMessages.append(error.localizedDescription)
                        failureLock.unlock()
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                Task { @MainActor in
                    self.refreshScheduledState(expectedCount: activeReminders.count,
                                               activeReminders: activeReminders,
                                               failures: failureMessages)
                }
            }
        }
    }

    private func refreshScheduledState(expectedCount: Int,
                                       activeReminders: [ReminderItem],
                                       failures: [String]) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let scheduled = requests.filter { request in
                request.identifier == Self.legacyDailyReminderID ||
                request.identifier.hasPrefix(Self.dailyReminderPrefix)
            }.count

            Task { @MainActor in
                self.scheduledReminderCount = scheduled

                if let firstFailure = failures.first {
                    self.statusMessage = "Could not schedule every reminder: \(firstFailure)"
                    return
                }

                let summary = self.timeSummary(for: activeReminders)
                if scheduled == expectedCount {
                    self.statusMessage = scheduled == 1
                        ? "1 daily reminder scheduled for \(summary)."
                        : "\(scheduled) daily reminders scheduled: \(summary)."
                } else {
                    self.statusMessage = "Scheduled \(scheduled) of \(expectedCount) reminders. Tap Save reminders again if that looks wrong."
                }
            }
        }
    }

    private func removeExistingReminderRequests(center: UNUserNotificationCenter, completion: @escaping () -> Void) {
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0 == Self.legacyDailyReminderID || $0.hasPrefix(Self.dailyReminderPrefix) }

            if !identifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
            }

            completion()
        }
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
    }

    private func timeSummary(for reminders: [ReminderItem]) -> String {
        let times = reminders.map { $0.formattedTime }
        if times.count <= 3 {
            return times.joined(separator: ", ")
        }
        return times.prefix(3).joined(separator: ", ") + " +\(times.count - 3) more"
    }
}
