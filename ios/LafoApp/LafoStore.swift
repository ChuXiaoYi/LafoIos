import Foundation
import UserNotifications

@MainActor
final class LafoStore: ObservableObject {
    @Published private(set) var records: [PoopRecord] = []
    @Published private(set) var settings: UserSettings = .defaults
    @Published private(set) var petProgress: PetProgress = .defaults
    @Published var lastSuccessMessage: String?

    private let calendar = Calendar.current
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    var privacyAccepted: Bool {
        settings.privacyAccepted
    }

    var todaySummary: DaySummary {
        summary(for: Date())
    }

    var currentMonthSummaries: [DaySummary] {
        summaries(inMonthOf: Date())
    }

    var stats: StatsSnapshot {
        makeStats()
    }

    var todayRecords: [PoopRecord] {
        records(on: Date())
    }

    var buddyMessage: String {
        if let message = lastSuccessMessage {
            return message
        }
        if stats.streakDays >= 7 {
            return "一周达成！你真的很会照顾自己！"
        }
        if stats.streakDays >= 3 {
            return "连续 \(stats.streakDays) 天啦，肠肠开始熟悉你的节奏了！"
        }
        if todaySummary.hasRecords {
            return "收到啦，今天也有好好了解自己！"
        }
        if records.isEmpty {
            return "从第一次记录开始，Lafo 就会陪着你。"
        }
        return "没关系，Lafo 一直都在，想起来再记就好 🌱"
    }

    var petMoodIcon: String {
        if petProgress.unlockedDecorationIDs.contains("week_crown") { return "🎉" }
        if todaySummary.hasRecords { return "☁️" }
        if petProgress.unlockedExpressionIDs.contains("streak_3") { return "😊" }
        return "🌱"
    }

    func acceptPrivacy() {
        settings.privacyAccepted = true
        save()
    }

    func addRecord(
        poopTime: Date,
        poopType: PoopType,
        mood: MoodType?,
        painLevel: PainLevel?,
        note: String,
        source: RecordSource = .manual
    ) {
        let trimmedNote = String(note.prefix(120))
        let energy = PoopRecord.energyValue(mood: mood, note: trimmedNote)
        let record = PoopRecord(
            poopTime: poopTime,
            poopType: poopType,
            mood: mood,
            painLevel: painLevel,
            note: trimmedNote,
            source: source,
            energyAwarded: energy
        )
        records.append(record)
        lastSuccessMessage = successMessage(for: poopType)
        awardEnergy(energy)
        debugLog("Lafo 本地记录已新增：source=\(source.rawValue), type=\(poopType.rawValue), count=\(records.count)")
        save()
    }

    func quickAddRecord() {
        let previousType = records.sorted { $0.poopTime < $1.poopTime }.last?.poopType ?? .normal
        addRecord(poopTime: Date(), poopType: previousType, mood: nil, painLevel: nil, note: "", source: .quick)
        lastSuccessMessage = "已快速记录一次轻松时刻 ✨"
    }

    func updateRecord(
        _ record: PoopRecord,
        poopTime: Date,
        poopType: PoopType,
        mood: MoodType?,
        painLevel: PainLevel?,
        note: String
    ) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            return
        }
        records[index].poopTime = poopTime
        records[index].poopType = poopType
        records[index].mood = mood
        records[index].painLevel = painLevel
        records[index].note = String(note.prefix(120))
        records[index].updatedAt = Date()
        lastSuccessMessage = "Lafo 已经帮你改好啦！"
        debugLog("Lafo 本地记录已更新：id=\(record.id.uuidString)")
        save()
    }

    func deleteRecord(_ record: PoopRecord) {
        records.removeAll { $0.id == record.id }
        debugLog("Lafo 本地记录已删除：id=\(record.id.uuidString), count=\(records.count)")
        save()
    }

    func clearAllLocalData() {
        records.removeAll()
        settings.reminderEnabled = false
        settings.petName = "Lafo 小肠肠"
        petProgress = .defaults
        lastSuccessMessage = nil
        cancelReminder()
        debugLog("Lafo 本地数据已清空")
        save()
    }

    func renamePet(_ name: String) {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.petName = cleaned.isEmpty ? "Lafo 小肠肠" : String(cleaned.prefix(16))
        save()
    }

    func setReminderEnabled(_ enabled: Bool) {
        settings.reminderEnabled = enabled
        save()
        if enabled {
            requestAndScheduleReminder()
        } else {
            cancelReminder()
        }
    }

    func updateReminderTime(_ date: Date) {
        settings.reminderTime = calendar.dateComponents([.hour, .minute], from: date)
        save()
        if settings.reminderEnabled {
            requestAndScheduleReminder()
        }
    }

    func updateReminderStyle(_ style: ReminderStyle) {
        settings.reminderStyle = style
        save()
        if settings.reminderEnabled {
            requestAndScheduleReminder()
        }
    }

    func updateNotificationDisplayMode(_ mode: NotificationDisplayMode) {
        settings.notificationDisplayMode = mode
        save()
        if settings.reminderEnabled {
            requestAndScheduleReminder()
        }
    }

    func time(for preset: TimePreset, referenceDate: Date = Date()) -> Date {
        switch preset {
        case .now:
            return Date()
        case .thisMorning:
            return date(on: referenceDate, hour: 8, minute: 0)
        case .thisNoon:
            return date(on: referenceDate, hour: 12, minute: 30)
        case .thisEvening:
            return date(on: referenceDate, hour: 20, minute: 0)
        case .yesterdayEvening:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate
            return date(on: yesterday, hour: 20, minute: 0)
        case .custom:
            return referenceDate
        }
    }

    func recentRecords(limit: Int = 3) -> [PoopRecord] {
        Array(records.sorted { $0.poopTime > $1.poopTime }.prefix(limit))
    }

    func records(on day: Date) -> [PoopRecord] {
        records
            .filter { calendar.isDate($0.poopTime, inSameDayAs: day) }
            .sorted { $0.poopTime > $1.poopTime }
    }

    func summary(for day: Date) -> DaySummary {
        DaySummary(day: calendar.startOfDay(for: day), records: records(on: day))
    }

    func summaries(inMonthOf date: Date) -> [DaySummary] {
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        var result: [DaySummary] = []
        var cursor = interval.start
        while cursor < interval.end {
            result.append(summary(for: cursor))
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else {
                break
            }
            cursor = next
        }
        return result
    }

    func makeStats(referenceDate: Date = Date()) -> StatsSnapshot {
        let todayStart = calendar.startOfDay(for: referenceDate)
        let weekStart = calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart
        let weekRecords = records.filter { $0.poopTime >= weekStart && $0.poopTime <= referenceDate }
        let weekPoopRecords = weekRecords.filter { $0.poopType.countsAsPoop }
        let monthDays = summaries(inMonthOf: referenceDate)
        let monthRecordedDays = monthDays.filter(\.hasRecords).count

        return StatsSnapshot(
            todayCount: summary(for: referenceDate).poopCount,
            weekCount: weekPoopRecords.count,
            weekAverage: Double(weekPoopRecords.count) / 7.0,
            streakDays: streakDays(referenceDate: referenceDate),
            mostCommonType: mostCommonPoopType(in: records),
            mostCommonTimeBucket: mostCommonTimeBucket(in: records),
            monthRecordedDays: monthRecordedDays
        )
    }

    func monthlyReview(for month: Date = Date()) -> MonthlyReview {
        let summaries = summaries(inMonthOf: month)
        let monthRecords = summaries.flatMap(\.records)
        let poopRecords = monthRecords.filter { $0.poopType.countsAsPoop }
        let recordedDays = summaries.filter(\.hasRecords).count
        let commonType = mostCommonPoopType(in: monthRecords)
        let commonTime = mostCommonTimeBucket(in: monthRecords)

        return MonthlyReview(
            month: calendar.dateInterval(of: .month, for: month)?.start ?? month,
            recordedDays: recordedDays,
            totalPoopCount: poopRecords.count,
            mostCommonType: commonType,
            mostCommonTimeBucket: commonTime,
            title: monthlyTitle(recordedDays: recordedDays)
        )
    }

    func exportCSVText() -> String {
        let formatter = ISO8601DateFormatter()
        let header = "id,createdAt,poopTime,poopType,mood,painLevel,note,updatedAt,source,energyAwarded"
        let rows = records
            .sorted { $0.poopTime < $1.poopTime }
            .map { record in
                [
                    record.id.uuidString,
                    formatter.string(from: record.createdAt),
                    formatter.string(from: record.poopTime),
                    record.poopType.rawValue,
                    record.mood?.rawValue ?? "",
                    record.painLevel?.rawValue ?? "",
                    csvEscape(record.note),
                    formatter.string(from: record.updatedAt),
                    record.source.rawValue,
                    "\(record.energyAwarded)"
                ].joined(separator: ",")
            }
        return ([header] + rows).joined(separator: "\n")
    }

    func reminderDateForPicker() -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = settings.reminderTime.hour ?? 21
        components.minute = settings.reminderTime.minute ?? 0
        return calendar.date(from: components) ?? Date()
    }

    func dismissSuccessMessage() {
        lastSuccessMessage = nil
    }

    func notificationBody() -> String {
        settings.notificationDisplayMode.notificationBodies.randomElement() ?? "Lafo 提醒"
    }

    private func successMessage(for type: PoopType) -> String {
        switch type {
        case .failed:
            return "肠肠收到，没拉出来也算认真记录。"
        case .normal:
            return "记录成功！肠肠收到啦 🌱"
        case .hard, .soft, .loose:
            return "Lafo 已经帮你记好啦！"
        }
    }

    private func streakDays(referenceDate: Date) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: referenceDate)

        // 如果今天还没记录，从昨天开始算，避免上午打开时给用户压力。
        if !summary(for: cursor).hasRecords,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }

        while summary(for: cursor).hasRecords {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return streak
    }

    private func mostCommonPoopType(in records: [PoopRecord]) -> PoopType? {
        let countedRecords = records.filter { $0.poopType.countsAsPoop }
        return Dictionary(grouping: countedRecords, by: \.poopType)
            .max { lhs, rhs in lhs.value.count < rhs.value.count }?
            .key
    }

    private func mostCommonTimeBucket(in records: [PoopRecord]) -> TimeBucket? {
        let countedRecords = records.filter { $0.poopType.countsAsPoop }
        return Dictionary(grouping: countedRecords) { TimeBucket(date: $0.poopTime, calendar: calendar) }
            .max { lhs, rhs in lhs.value.count < rhs.value.count }?
            .key
    }

    private func awardEnergy(_ energy: Int) {
        petProgress.totalEnergy += energy
        evaluatePetUnlocks()
    }

    private func evaluatePetUnlocks() {
        let streak = streakDays(referenceDate: Date())
        if streak >= 3 {
            petProgress.unlockedExpressionIDs.insert("streak_3")
        }
        if streak >= 7 {
            petProgress.unlockedDecorationIDs.insert("week_crown")
        }
        petProgress.lastEvaluatedAt = Date()
        // 成长体系只做正向陪伴，不因删除或停记扣能量，避免制造断签压力。
    }

    private func monthlyTitle(recordedDays: Int) -> String {
        switch recordedDays {
        case 0:
            return "慢慢来观察员"
        case 1...5:
            return "轻松起步员"
        case 6...14:
            return "节奏发现家"
        case 15...24:
            return "肠肠陪伴家"
        default:
            return "小肚肚月度达人"
        }
    }

    private func date(on date: Date, hour: Int, minute: Int) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? date
    }

    private func requestAndScheduleReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [settings] granted, _ in
            guard granted else {
                Self.debugLog("Lafo 提醒权限未开启")
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "Lafo"
            // 隐私模式文案由 NotificationDisplayMode 统一控制，避免锁屏出现敏感词。
            content.body = settings.notificationDisplayMode.notificationBodies.randomElement() ?? "Lafo 提醒"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: settings.reminderTime, repeats: true)
            let request = UNNotificationRequest(identifier: "lafo.daily.reminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lafo.daily.reminder"])
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    Self.debugLog("Lafo 提醒注册失败：\(error.localizedDescription)")
                } else {
                    Self.debugLog("Lafo 提醒已注册")
                }
            }
        }
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lafo.daily.reminder"])
    }

    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            let payload = try decoder.decode(LocalPayload.self, from: data)
            records = payload.records
            settings = payload.settings
            petProgress = payload.petProgress ?? PetProgress(
                totalEnergy: payload.records.reduce(0) { $0 + $1.energyAwarded },
                unlockedExpressionIDs: [],
                unlockedDecorationIDs: [],
                lastEvaluatedAt: Date()
            )
            evaluatePetUnlocks()
        } catch {
            records = []
            settings = .defaults
            petProgress = .defaults
            debugLog("Lafo 本地数据未加载，使用默认状态：\(error.localizedDescription)")
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
            let payload = LocalPayload(records: records, settings: settings, petProgress: petProgress)
            let data = try encoder.encode(payload)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            debugLog("Lafo 本地数据保存失败：\(error.localizedDescription)")
        }
    }

    private nonisolated static func debugLog(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }

    private func debugLog(_ message: String) {
        Self.debugLog(message)
    }

    private func csvEscape(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private var appSupportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Lafo", isDirectory: true)
    }

    private var storeURL: URL {
        appSupportDirectory.appendingPathComponent("lafo-local-store.json")
    }
}

private struct LocalPayload: Codable {
    var records: [PoopRecord]
    var settings: UserSettings
    var petProgress: PetProgress?
}
