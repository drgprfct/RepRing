import Foundation
import SwiftUI

enum ExerciseKind: String, CaseIterable, Identifiable, Codable {
    case crunches
    case pushUps

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crunches: "Crunches"
        case .pushUps: "Push-ups"
        }
    }

    var shortTitle: String {
        switch self {
        case .crunches: "Crunch"
        case .pushUps: "Push"
        }
    }

    var imageName: String {
        switch self {
        case .crunches: "crunch_badge"
        case .pushUps: "pushup_badge"
        }
    }

    var tint: Color {
        switch self {
        case .crunches: Color.teal
        case .pushUps: Color.orange
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Automatic"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon.stars"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct DailyLog: Codable, Identifiable, Equatable {
    var id: String { dateKey }
    var dateKey: String
    var crunches: Int
    var pushUps: Int

    var total: Int { crunches + pushUps }

    func value(for kind: ExerciseKind) -> Int {
        switch kind {
        case .crunches: crunches
        case .pushUps: pushUps
        }
    }
}

struct ReminderItem: Codable, Identifiable, Equatable {
    var id: UUID
    var time: Date
    var isEnabled: Bool

    init(id: UUID = UUID(),
         time: Date = RepSettings.defaultReminderTime(hour: 18, minute: 30),
         isEnabled: Bool = true) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
    }

    var formattedTime: String {
        time.formatted(date: .omitted, time: .shortened)
    }
}

struct RepSettings: Codable, Equatable {
    var crunchSet: Int
    var pushSet: Int
    var crunchGoal: Int
    var pushGoal: Int
    var reminders: [ReminderItem]
    var healthAutoExportEnabled: Bool
    var lastHealthExportSignature: String?
    var appearanceMode: AppearanceMode

    init(crunchSet: Int = 20,
         pushSet: Int = 10,
         crunchGoal: Int = 100,
         pushGoal: Int = 50,
         reminders: [ReminderItem]? = nil,
         healthAutoExportEnabled: Bool = false,
         lastHealthExportSignature: String? = nil,
         appearanceMode: AppearanceMode = .system) {
        self.crunchSet = crunchSet
        self.pushSet = pushSet
        self.crunchGoal = crunchGoal
        self.pushGoal = pushGoal
        self.reminders = reminders ?? Self.defaultReminders
        self.healthAutoExportEnabled = healthAutoExportEnabled
        self.lastHealthExportSignature = lastHealthExportSignature
        self.appearanceMode = appearanceMode
    }

    static var defaultReminders: [ReminderItem] {
        [
            ReminderItem(time: defaultReminderTime(hour: 8, minute: 0), isEnabled: false),
            ReminderItem(time: defaultReminderTime(hour: 13, minute: 0), isEnabled: false),
            ReminderItem(time: defaultReminderTime(hour: 18, minute: 30), isEnabled: false)
        ]
    }

    static func defaultReminderTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    private enum CodingKeys: String, CodingKey {
        case crunchSet
        case pushSet
        case crunchGoal
        case pushGoal
        case reminders
        case healthAutoExportEnabled
        case autoExportToHealth
        case lastHealthExportSignature
        case appearanceMode
        case reminderEnabled
        case reminderTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        crunchSet = try container.decodeIfPresent(Int.self, forKey: .crunchSet) ?? 20
        pushSet = try container.decodeIfPresent(Int.self, forKey: .pushSet) ?? 10
        crunchGoal = try container.decodeIfPresent(Int.self, forKey: .crunchGoal) ?? 100
        pushGoal = try container.decodeIfPresent(Int.self, forKey: .pushGoal) ?? 50
        healthAutoExportEnabled = try container.decodeIfPresent(Bool.self, forKey: .healthAutoExportEnabled)
            ?? container.decodeIfPresent(Bool.self, forKey: .autoExportToHealth)
            ?? false
        lastHealthExportSignature = try container.decodeIfPresent(String.self, forKey: .lastHealthExportSignature)
        appearanceMode = try container.decodeIfPresent(AppearanceMode.self, forKey: .appearanceMode) ?? .system

        if let decodedReminders = try container.decodeIfPresent([ReminderItem].self, forKey: .reminders),
           !decodedReminders.isEmpty {
            reminders = decodedReminders
        } else if let legacyTime = try container.decodeIfPresent(Date.self, forKey: .reminderTime) {
            let legacyEnabled = try container.decodeIfPresent(Bool.self, forKey: .reminderEnabled) ?? false
            reminders = [ReminderItem(time: legacyTime, isEnabled: legacyEnabled)]
        } else {
            reminders = Self.defaultReminders
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(crunchSet, forKey: .crunchSet)
        try container.encode(pushSet, forKey: .pushSet)
        try container.encode(crunchGoal, forKey: .crunchGoal)
        try container.encode(pushGoal, forKey: .pushGoal)
        try container.encode(reminders, forKey: .reminders)
        try container.encode(healthAutoExportEnabled, forKey: .healthAutoExportEnabled)
        try container.encodeIfPresent(lastHealthExportSignature, forKey: .lastHealthExportSignature)
        try container.encode(appearanceMode, forKey: .appearanceMode)
    }
}
