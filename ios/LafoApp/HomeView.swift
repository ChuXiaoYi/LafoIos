import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LafoStore
    @State private var recordMode: RecordViewMode?
    @State private var deletingRecord: PoopRecord?
    @State private var quickBurstVisible = false
    @State private var longPressTriggered = false

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.homePage.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        heroCard
                        quickButton
                        buddyCard
                        recentRecordsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }

                if quickBurstVisible {
                    Text("+1 ✨")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(LafoTheme.forest)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .modifier(LafoTheme.cardShadow())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $recordMode) { mode in
                NavigationStack {
                    RecordView(mode: mode)
                }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
            }
            .alert("删除这条记录？", isPresented: deleteBinding) {
                Button("取消", role: .cancel) {
                    deletingRecord = nil
                }
                Button("删除", role: .destructive) {
                    if let deletingRecord {
                        store.deleteRecord(deletingRecord)
                    }
                    deletingRecord = nil
                }
            } message: {
                Text("删除后首页、日历和趋势会同步更新。")
            }
            .alert("Lafo", isPresented: successBinding) {
                Button("好呀") {
                    store.dismissSuccessMessage()
                }
            } message: {
                Text(store.lastSuccessMessage ?? "")
            }
        }
    }

    private var successBinding: Binding<Bool> {
        Binding(
            get: { store.lastSuccessMessage != nil },
            set: { if !$0 { store.dismissSuccessMessage() } }
        )
    }

    private var deleteBinding: Binding<Bool> {
        Binding(
            get: { deletingRecord != nil },
            set: { if !$0 { deletingRecord = nil } }
        )
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今天肠肠还好吗？")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(LafoTheme.textStrong)

                    Text("记录一下，不焦虑，只是更了解自己。")
                        .font(.subheadline)
                        .foregroundStyle(LafoTheme.mutedText)
                }

                Spacer()

                VStack(spacing: 5) {
                    Text(store.todaySummary.latestRecord?.poopType.icon ?? "🌱")
                        .font(.system(size: 34))
                    Text("\(store.todaySummary.poopCount)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(LafoTheme.forest)
                    Text("今日次数")
                        .font(.caption)
                        .foregroundStyle(LafoTheme.mutedText)
                }
                .frame(width: 92)
                .frame(minHeight: 110)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            HStack(spacing: 10) {
                statPill(title: "连续", value: "\(store.stats.streakDays) 天")
                statPill(title: "本周", value: "\(store.stats.weekCount) 次")
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var quickButton: some View {
        Button {
            guard !longPressTriggered else {
                longPressTriggered = false
                return
            }
            recordMode = .create
        } label: {
            HStack {
                Text("我拉了 💩")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .background(LafoTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .modifier(LafoTheme.cardShadow())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.55).onEnded { _ in
                longPressTriggered = true
                store.quickAddRecord()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                    quickBurstVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        quickBurstVisible = false
                    }
                    longPressTriggered = false
                }
            }
        )
    }

    private var backfillButton: some View {
        Button {
            recordMode = .backfill
        } label: {
            Label("补记一下", systemImage: "clock.arrow.circlepath")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryButtonStyle())
    }

    private var buddyCard: some View {
        HStack(spacing: 14) {
            Text(store.petMoodIcon)
                .font(.system(size: 44))
                .frame(width: 70, height: 70)
                .background(LafoTheme.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(store.settings.petName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LafoTheme.text)
                Text(store.buddyMessage)
                    .font(.subheadline)
                    .foregroundStyle(LafoTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(LafoTheme.warmCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var recentRecordsCard: some View {
        let records = store.recentRecords(limit: 3)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("最近记录")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LafoTheme.text)
                Spacer()
                Text(records.isEmpty ? "暂无" : "\(records.count) 条")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LafoTheme.amberText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(LafoTheme.selected)
                    .clipShape(Capsule())
            }

            backfillButton

            if records.isEmpty {
                Text("还没有记录哦。从第一次轻松时刻开始，Lafo 就会陪着你。")
                    .font(.subheadline)
                    .foregroundStyle(LafoTheme.mutedText)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        Button {
                            recordMode = .edit(record)
                        } label: {
                            HStack(spacing: 10) {
                                RecordCompactRow(record: record)

                                Menu {
                                    Button("编辑") {
                                        recordMode = .edit(record)
                                    }
                                    Button("删除", role: .destructive) {
                                        deletingRecord = record
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .frame(width: 32, height: 32)
                                        .background(LafoTheme.paleGreen)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(LafoTheme.mutedText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LafoTheme.softGreen)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct RecordCompactRow: View {
    let record: PoopRecord

    var body: some View {
        HStack(spacing: 12) {
            Text(record.poopType.icon)
                .font(.title3)
                .frame(width: 42, height: 42)
                .background(record.poopType.tint)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.summaryText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(LafoTheme.text)
                    .lineLimit(1)
                Text(record.poopTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
                if let mood = record.mood {
                    Text("感受：\(mood.label)")
                        .font(.caption2)
                        .foregroundStyle(LafoTheme.mutedText)
                }
            }

            Spacer()
        }
    }
}
