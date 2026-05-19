import Foundation
import Combine

@MainActor
final class RepStore: ObservableObject {
    @Published var settings: RepSettings {
        didSet { saveSettings() }
    }

    @Published private(set) var logs: [String: DailyLog] {
        didSet { saveLogs() }
    }

    private let defaults: UserDefaults
    private let settingsKey = "RepRing.settings.v1"
    private let logsKey = "RepRing.logs.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(RepSettings.self, from: data) {
            settings = decoded
        } else {
            settings = RepSettings()
        }

        if let data = defaults.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([String: DailyLog].self, from: data) {
            logs = decoded
        } else {
            logs = [:]
        }

        ensureTodayExists()
    }

    var today: DailyLog {
        logs[Self.dayKey()] ?? DailyLog(dateKey: Self.dayKey(), crunches: 0, pushUps: 0)
    }

    var dailyTotalGoal: Int { settings.crunchGoal + settings.pushGoal }

    var todayTotalProgress: Double {
        guard dailyTotalGoal > 0 else { return 0 }
        return min(Double(today.total) / Double(dailyTotalGoal), 1)
    }

    var activeReminderCount: Int {
        settings.reminders.filter(\.isEnabled).count
    }

    var reminderSummary: String {
        switch activeReminderCount {
        case 0: "No reminders set"
        case 1: "1 reminder today"
        default: "\(activeReminderCount) reminders today"
        }
    }

    func progress(for kind: ExerciseKind) -> Double {
        let current = today.value(for: kind)
        let goal = goal(for: kind)
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1)
    }

    func setSize(for kind: ExerciseKind) -> Int {
        switch kind {
        case .crunches: settings.crunchSet
        case .pushUps: settings.pushSet
        }
    }

    func goal(for kind: ExerciseKind) -> Int {
        switch kind {
        case .crunches: settings.crunchGoal
        case .pushUps: settings.pushGoal
        }
    }

    func updateSetSize(_ value: Int, for kind: ExerciseKind) {
        switch kind {
        case .crunches: settings.crunchSet = value
        case .pushUps: settings.pushSet = value
        }
    }

    func updateGoal(_ value: Int, for kind: ExerciseKind) {
        switch kind {
        case .crunches: settings.crunchGoal = value
        case .pushUps: settings.pushGoal = value
        }
    }

    func setHealthAutoExportEnabled(_ isEnabled: Bool) {
        settings.healthAutoExportEnabled = isEnabled
    }

    func healthExportSignature(for log: DailyLog) -> String {
        "\(log.dateKey)|crunches:\(log.crunches)|pushups:\(log.pushUps)"
    }

    func markHealthExported(signature: String) {
        settings.lastHealthExportSignature = signature
    }

    func clearHealthExportSignature() {
        settings.lastHealthExportSignature = nil
    }

    func addReminder() {
        let calendar = Calendar.current
        let baseTime = settings.reminders.last?.time ?? RepSettings.defaultReminderTime(hour: 18, minute: 30)
        let nextTime = calendar.date(byAdding: .hour, value: 2, to: baseTime) ?? baseTime
        settings.reminders.append(ReminderItem(time: nextTime, isEnabled: true))
    }

    func removeReminder(id: UUID) {
        settings.reminders.removeAll { $0.id == id }
        if settings.reminders.isEmpty {
            settings.reminders = [ReminderItem(time: RepSettings.defaultReminderTime(hour: 18, minute: 30), isEnabled: false)]
        }
    }

    func addStandardSet(for kind: ExerciseKind) {
        addReps(setSize(for: kind), for: kind)
    }

    func addReps(_ amount: Int, for kind: ExerciseKind) {
        guard amount > 0 else { return }
        var log = today
        switch kind {
        case .crunches: log.crunches += amount
        case .pushUps: log.pushUps += amount
        }
        logs[log.dateKey] = log
    }

    func undoStandardSet(for kind: ExerciseKind) {
        var log = today
        switch kind {
        case .crunches: log.crunches = max(0, log.crunches - settings.crunchSet)
        case .pushUps: log.pushUps = max(0, log.pushUps - settings.pushSet)
        }
        logs[log.dateKey] = log
    }

    func resetToday() {
        logs[Self.dayKey()] = DailyLog(dateKey: Self.dayKey(), crunches: 0, pushUps: 0)
        clearHealthExportSignature()
    }

    func recentLogs(days: Int = 7) -> [DailyLog] {
        let calendar = Calendar.current
        return (0..<days).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let key = Self.dayKey(for: date)
            return logs[key] ?? DailyLog(dateKey: key, crunches: 0, pushUps: 0)
        }
    }

    private func ensureTodayExists() {
        let key = Self.dayKey()
        if logs[key] == nil {
            logs[key] = DailyLog(dateKey: key, crunches: 0, pushUps: 0)
        }
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }

    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            defaults.set(encoded, forKey: logsKey)
        }
    }

    static func dayKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
