import SwiftUI

enum RecordViewMode: Identifiable {
    case create
    case backfill
    case edit(PoopRecord)

    var id: String {
        switch self {
        case .create: return "create"
        case .backfill: return "backfill"
        case .edit(let record): return record.id.uuidString
        }
    }
}

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: LafoStore

    let mode: RecordViewMode

    @State private var poopTime: Date
    @State private var poopType: PoopType?
    @State private var mood: MoodType?
    @State private var painLevel: PainLevel?
    @State private var note: String
    @State private var timePreset: TimePreset
    @State private var validationMessage: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    private let presetColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    init(mode: RecordViewMode) {
        self.mode = mode
        switch mode {
        case .create:
            _poopTime = State(initialValue: Date())
            _poopType = State(initialValue: nil)
            _mood = State(initialValue: nil)
            _painLevel = State(initialValue: nil)
            _note = State(initialValue: "")
            _timePreset = State(initialValue: .now)
        case .backfill:
            _poopTime = State(initialValue: Date())
            _poopType = State(initialValue: nil)
            _mood = State(initialValue: nil)
            _painLevel = State(initialValue: nil)
            _note = State(initialValue: "")
            _timePreset = State(initialValue: .now)
        case .edit(let record):
            _poopTime = State(initialValue: record.poopTime)
            _poopType = State(initialValue: record.poopType)
            _mood = State(initialValue: record.mood)
            _painLevel = State(initialValue: record.painLevel)
            _note = State(initialValue: record.note)
            _timePreset = State(initialValue: .custom)
        }
    }

    var body: some View {
        ZStack {
            LafoTheme.page.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    timeCard
                    optionSection(title: "这次是什么状态？", tip: "必填", selection: $poopType, options: PoopType.allCases)
                    optionSection(title: "现在感觉如何？", tip: "选填", selection: $mood, options: MoodType.allCases)
                    optionSection(title: "有没有腹痛？", tip: "选填", selection: $painLevel, options: PainLevel.allCases)
                    noteSection
                    submitButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") {
                    dismiss()
                }
                .foregroundStyle(LafoTheme.forest)
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create: return "记录"
        case .backfill: return "补记一下"
        case .edit: return "编辑记录"
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("保存轻松时刻")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(LafoTheme.textStrong)
            Text("简单选一下，不用认真到紧张。")
                .font(.subheadline)
                .foregroundStyle(LafoTheme.mutedText)
        }
    }

    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("什么时候？")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(LafoTheme.text)
                Text("补记会按这个时间进日历")
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
            }

            LazyVGrid(columns: presetColumns, spacing: 8) {
                ForEach(TimePreset.allCases) { preset in
                    Button {
                        timePreset = preset
                        if preset != .custom {
                            poopTime = store.time(for: preset)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(preset.icon)
                                .font(.title3)
                            Text(preset.label)
                                .font(.caption2.weight(timePreset == preset ? .bold : .regular))
                                .foregroundStyle(timePreset == preset ? LafoTheme.deepGreen : LafoTheme.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .background(timePreset == preset ? LafoTheme.selected : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(timePreset == preset ? LafoTheme.primary : Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if timePreset == .custom {
                VStack(spacing: 0) {
                    DatePicker("日期", selection: $poopTime, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.vertical, 4)
                    Divider().opacity(0.35)
                    DatePicker("时间", selection: $poopTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .padding(.vertical, 4)
                }
                .font(.subheadline)
                .padding(.top, 4)
            } else {
                Text("当前选择：\(poopTime.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private func optionSection<Option: LafoOption>(
        title: String,
        tip: String,
        selection: Binding<Option?>,
        options: [Option]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(LafoTheme.text)
                Text(tip)
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(options) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        VStack(spacing: 8) {
                            Text(option.icon)
                                .font(.system(size: 26))
                            Text(option.label)
                                .font(.caption.weight(selection.wrappedValue == option ? .bold : .regular))
                                .foregroundStyle(selection.wrappedValue == option ? LafoTheme.deepGreen : LafoTheme.text)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .background(selection.wrappedValue == option ? LafoTheme.selected : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selection.wrappedValue == option ? LafoTheme.primary : Color.black.opacity(0.08), lineWidth: 1.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("备注")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(LafoTheme.text)
                Text("选填")
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
                Spacer()
                Text("\(note.count)/120")
                    .font(.caption)
                    .foregroundStyle(LafoTheme.mutedText)
            }

            TextField("例如：今天吃了火锅、喝水太少、早上很顺畅", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .padding(14)
                .background(Color(hex: 0xFAFAFA))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onChange(of: note) { _, newValue in
                    if newValue.count > 120 {
                        note = String(newValue.prefix(120))
                    }
                }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var submitButton: some View {
        VStack(spacing: 10) {
            if let validationMessage {
                Text(validationMessage)
                    .font(.footnote)
                    .foregroundStyle(LafoTheme.amberText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                save()
            } label: {
                Label("记好了", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private func save() {
        guard let poopType else {
            validationMessage = "先选一下这次的状态吧 🌱"
            return
        }

        switch mode {
        case .create:
            store.addRecord(poopTime: poopTime, poopType: poopType, mood: mood, painLevel: painLevel, note: note)
        case .backfill:
            store.addRecord(poopTime: poopTime, poopType: poopType, mood: mood, painLevel: painLevel, note: note, source: .backfill)
        case .edit(let record):
            store.updateRecord(record, poopTime: poopTime, poopType: poopType, mood: mood, painLevel: painLevel, note: note)
        }
        dismiss()
    }
}
