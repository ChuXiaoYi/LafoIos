import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: LafoStore
    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var editingRecord: PoopRecord?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.homePage.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        monthHeader
                        weekdayHeader
                        monthGrid
                        dayDetail
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("肠肠日历")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingRecord) { record in
                NavigationStack {
                    RecordView(mode: .edit(record))
                }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(displayedMonth.formatted(.dateTime.year().month(.wide)))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LafoTheme.text)
                Text("看看最近的小肚肚节奏")
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
            }

            Spacer()

            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .foregroundStyle(LafoTheme.forest)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                Text(day)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LafoTheme.mutedText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(calendarCells, id: \.self) { date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 58)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var dayDetail: some View {
        let records = store.records(on: selectedDate)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate.formatted(.dateTime.month().day()))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(LafoTheme.text)
                    Text("规律不是压力，是更了解自己")
                        .font(.caption)
                        .foregroundStyle(LafoTheme.mutedText)
                }

                Spacer()

                Text("\(records.filter { $0.poopType.countsAsPoop }.count) 次")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LafoTheme.amberText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(LafoTheme.selected)
                    .clipShape(Capsule())
            }

            if records.isEmpty {
                Text("这一天还没有记录。")
                    .font(.subheadline)
                    .foregroundStyle(LafoTheme.mutedText)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        recordDetailRow(record)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var calendarCells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leadingEmptyCount = firstWeekday - 1
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: interval.start)
        }
        return Array(repeating: nil, count: leadingEmptyCount) + days
    }

    private func dayCell(_ date: Date) -> some View {
        let summary = store.summary(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : LafoTheme.text)

                if summary.hasRecords {
                    Text(summary.latestRecord?.poopType.icon ?? "🌱")
                        .font(.caption)
                    Text(summary.poopCount == 0 ? "记录" : "\(summary.poopCount)次")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : LafoTheme.amberText)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(isSelected ? LafoTheme.primary : (summary.hasRecords ? LafoTheme.warmCard : Color.clear))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func recordDetailRow(_ record: PoopRecord) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(record.poopType.icon)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(record.poopType.tint)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(record.poopTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LafoTheme.forest)
                Text(record.summaryText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(LafoTheme.text)
                if let pain = record.painLevel {
                    Text("腹痛：\(pain.label)")
                        .font(.caption)
                        .foregroundStyle(LafoTheme.mutedText)
                }
                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.caption)
                        .foregroundStyle(LafoTheme.mutedText)
                }
            }

            Spacer()

            Menu {
                Button("编辑") {
                    editingRecord = record
                }
                Button("删除", role: .destructive) {
                    store.deleteRecord(record)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 34, height: 34)
                    .background(LafoTheme.paleGreen)
                    .clipShape(Circle())
            }
        }
    }
}
