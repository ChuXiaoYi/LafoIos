import Foundation
import SwiftUI

protocol LafoOption: RawRepresentable, CaseIterable, Codable, Identifiable, Equatable where RawValue == String {
    var label: String { get }
    var icon: String { get }
}

extension LafoOption {
    var id: String { rawValue }
    var displayText: String { "\(icon) \(label)" }
}

enum PoopType: String, LafoOption {
    case hard
    case normal
    case soft
    case loose
    case failed

    var icon: String {
        switch self {
        case .hard: return "🪨"
        case .normal: return "🍌"
        case .soft: return "🍦"
        case .loose: return "💧"
        case .failed: return "☁️"
        }
    }

    var label: String {
        switch self {
        case .hard: return "偏硬"
        case .normal: return "正常"
        case .soft: return "偏软"
        case .loose: return "偏稀"
        case .failed: return "没拉出来"
        }
    }

    var cuteLine: String {
        switch self {
        case .hard: return "今天有点倔强"
        case .normal: return "完美表现"
        case .soft: return "有点松软"
        case .loose: return "肚肚在抗议"
        case .failed: return "肠肠暂停营业"
        }
    }

    var countsAsPoop: Bool {
        self != .failed
    }

    var tint: Color {
        switch self {
        case .hard: return Color(hex: 0xF4D8AE)
        case .normal: return Color(hex: 0xFFE68A)
        case .soft: return Color(hex: 0xFFF4D6)
        case .loose: return Color(hex: 0xDFF2FF)
        case .failed: return Color(hex: 0xECECEC)
        }
    }
}

enum MoodType: String, LafoOption {
    case great
    case good
    case normal
    case uncomfortable

    var icon: String {
        switch self {
        case .great: return "✨"
        case .good: return "🙂"
        case .normal: return "🌿"
        case .uncomfortable: return "😵‍💫"
        }
    }

    var label: String {
        switch self {
        case .great: return "超轻松"
        case .good: return "还不错"
        case .normal: return "一般般"
        case .uncomfortable: return "有点难受"
        }
    }
}

enum PainLevel: String, LafoOption {
    case none
    case mild
    case obvious

    var icon: String {
        switch self {
        case .none: return "🌱"
        case .mild: return "🍃"
        case .obvious: return "🫧"
        }
    }

    var label: String {
        switch self {
        case .none: return "无"
        case .mild: return "轻微"
        case .obvious: return "明显"
        }
    }
}

enum ReminderStyle: String, LafoOption {
    case cute
    case gentle
    case funny
    case minimal

    var icon: String {
        switch self {
        case .cute: return "🌱"
        case .gentle: return "☁️"
        case .funny: return "😄"
        case .minimal: return "•"
        }
    }

    var label: String {
        switch self {
        case .cute: return "可爱"
        case .gentle: return "温柔"
        case .funny: return "搞笑"
        case .minimal: return "极简"
        }
    }

    var notificationBodies: [String] {
        switch self {
        case .cute:
            return ["今天肠肠营业了吗？", "记一记今天的小肚肚状态吧 🌱"]
        case .gentle:
            return ["不用认真到紧张，顺手记一下就好", "Lafo 陪你看看今天的节奏"]
        case .funny:
            return ["小肚肚今天有播报吗？", "今天的轻松时刻上线了吗？"]
        case .minimal:
            return ["记录一下今天", "Lafo 提醒"]
        }
    }
}

enum RecordSource: String, Codable, CaseIterable {
    case manual
    case quick
    case backfill
}

enum NotificationDisplayMode: String, LafoOption {
    case cute
    case privateMode = "private"
    case minimal

    var icon: String {
        switch self {
        case .cute: return "🌱"
        case .privateMode: return "🔒"
        case .minimal: return "•"
        }
    }

    var label: String {
        switch self {
        case .cute: return "可爱模式"
        case .privateMode: return "隐私模式"
        case .minimal: return "极简模式"
        }
    }

    var notificationBodies: [String] {
        switch self {
        case .cute:
            return ["记一记今天的小肚肚状态吧 🌱", "Lafo 想知道你今天过得轻不轻松"]
        case .privateMode:
            return ["Lafo 有一条温柔提醒 🌱", "今天也可以给自己留个小记录"]
        case .minimal:
            return ["Lafo 提醒", "记录一下今天"]
        }
    }
}

enum TimePreset: String, LafoOption {
    case now
    case thisMorning
    case thisNoon
    case thisEvening
    case yesterdayEvening
    case custom

    var icon: String {
        switch self {
        case .now: return "⚡"
        case .thisMorning: return "🌤️"
        case .thisNoon: return "☀️"
        case .thisEvening: return "🌙"
        case .yesterdayEvening: return "🕘"
        case .custom: return "✍️"
        }
    }

    var label: String {
        switch self {
        case .now: return "刚刚"
        case .thisMorning: return "今天早上"
        case .thisNoon: return "今天中午"
        case .thisEvening: return "今天晚上"
        case .yesterdayEvening: return "昨天晚上"
        case .custom: return "自定义时间"
        }
    }
}

enum TimeBucket: String, Codable, Equatable {
    case earlyMorning
    case morning
    case afternoon
    case evening
    case lateNight

    init(date: Date, calendar: Calendar = .current) {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<9: self = .earlyMorning
        case 9..<12: self = .morning
        case 12..<18: self = .afternoon
        case 18..<23: self = .evening
        default: self = .lateNight
        }
    }

    var label: String {
        switch self {
        case .earlyMorning: return "早上"
        case .morning: return "上午"
        case .afternoon: return "下午"
        case .evening: return "晚上"
        case .lateNight: return "深夜"
        }
    }
}

struct PoopRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var poopTime: Date
    var poopType: PoopType
    var mood: MoodType?
    var painLevel: PainLevel?
    var note: String
    var updatedAt: Date
    var source: RecordSource
    var energyAwarded: Int

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        poopTime: Date = Date(),
        poopType: PoopType,
        mood: MoodType? = nil,
        painLevel: PainLevel? = nil,
        note: String = "",
        updatedAt: Date = Date(),
        source: RecordSource = .manual,
        energyAwarded: Int? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.poopTime = poopTime
        self.poopType = poopType
        self.mood = mood
        self.painLevel = painLevel
        self.note = note
        self.updatedAt = updatedAt
        self.source = source
        self.energyAwarded = energyAwarded ?? PoopRecord.energyValue(mood: mood, note: note)
    }

    var summaryText: String {
        [poopType.displayText, mood?.displayText]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    static func energyValue(mood: MoodType?, note: String) -> Int {
        mood != nil && !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 8 : 5
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case poopTime
        case poopType
        case mood
        case painLevel
        case note
        case updatedAt
        case source
        case energyAwarded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        poopTime = try container.decode(Date.self, forKey: .poopTime)
        poopType = try container.decode(PoopType.self, forKey: .poopType)
        mood = try container.decodeIfPresent(MoodType.self, forKey: .mood)
        painLevel = try container.decodeIfPresent(PainLevel.self, forKey: .painLevel)
        note = try container.decode(String.self, forKey: .note)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        source = try container.decodeIfPresent(RecordSource.self, forKey: .source) ?? .manual
        energyAwarded = try container.decodeIfPresent(Int.self, forKey: .energyAwarded) ?? PoopRecord.energyValue(mood: mood, note: note)
    }
}

struct UserSettings: Codable, Equatable {
    var reminderEnabled: Bool
    var reminderTime: DateComponents
    var reminderStyle: ReminderStyle
    var notificationDisplayMode: NotificationDisplayMode
    var firstLaunchDate: Date
    var privacyAccepted: Bool
    var petName: String

    static var defaults: UserSettings {
        UserSettings(
            reminderEnabled: false,
            reminderTime: DateComponents(hour: 21, minute: 0),
            reminderStyle: .cute,
            notificationDisplayMode: .cute,
            firstLaunchDate: Date(),
            privacyAccepted: false,
            petName: "Lafo 小肠肠"
        )
    }

    private enum CodingKeys: String, CodingKey {
        case reminderEnabled
        case reminderTime
        case reminderStyle
        case notificationDisplayMode
        case firstLaunchDate
        case privacyAccepted
        case petName
    }

    init(
        reminderEnabled: Bool,
        reminderTime: DateComponents,
        reminderStyle: ReminderStyle,
        notificationDisplayMode: NotificationDisplayMode,
        firstLaunchDate: Date,
        privacyAccepted: Bool,
        petName: String
    ) {
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.reminderStyle = reminderStyle
        self.notificationDisplayMode = notificationDisplayMode
        self.firstLaunchDate = firstLaunchDate
        self.privacyAccepted = privacyAccepted
        self.petName = petName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reminderEnabled = try container.decode(Bool.self, forKey: .reminderEnabled)
        reminderTime = try container.decode(DateComponents.self, forKey: .reminderTime)
        reminderStyle = try container.decodeIfPresent(ReminderStyle.self, forKey: .reminderStyle) ?? .cute
        notificationDisplayMode = try container.decodeIfPresent(NotificationDisplayMode.self, forKey: .notificationDisplayMode) ?? .cute
        firstLaunchDate = try container.decode(Date.self, forKey: .firstLaunchDate)
        privacyAccepted = try container.decode(Bool.self, forKey: .privacyAccepted)
        petName = try container.decode(String.self, forKey: .petName)
    }
}

struct DaySummary: Identifiable, Equatable {
    let day: Date
    let records: [PoopRecord]

    var id: Date { day }
    var recordCount: Int { records.count }
    var poopCount: Int { records.filter { $0.poopType.countsAsPoop }.count }
    var latestRecord: PoopRecord? { records.sorted { $0.poopTime < $1.poopTime }.last }
    var hasRecords: Bool { !records.isEmpty }
}

struct StatsSnapshot: Equatable {
    let todayCount: Int
    let weekCount: Int
    let weekAverage: Double
    let streakDays: Int
    let mostCommonType: PoopType?
    let mostCommonTimeBucket: TimeBucket?
    let monthRecordedDays: Int
}

struct PetProgress: Codable, Equatable {
    var totalEnergy: Int
    var unlockedExpressionIDs: Set<String>
    var unlockedDecorationIDs: Set<String>
    var lastEvaluatedAt: Date

    static var defaults: PetProgress {
        PetProgress(
            totalEnergy: 0,
            unlockedExpressionIDs: [],
            unlockedDecorationIDs: [],
            lastEvaluatedAt: Date()
        )
    }
}

struct MonthlyReview: Equatable {
    let month: Date
    let recordedDays: Int
    let totalPoopCount: Int
    let mostCommonType: PoopType?
    let mostCommonTimeBucket: TimeBucket?
    let title: String
}
