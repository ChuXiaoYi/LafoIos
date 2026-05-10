import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: LafoStore
    @State private var petNameDraft = ""
    @State private var showingClearAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.homePage.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        reminderCard
                        petCard
                        dataCard
                        policyCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                petNameDraft = store.settings.petName
            }
            .alert("清空本地数据？", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) {
                    store.clearAllLocalData()
                }
            } message: {
                Text("这会删除本机上的所有 Lafo 记录，操作后无法在 App 内恢复。")
            }
        }
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("提醒设置")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            Toggle("每日提醒", isOn: Binding(
                get: { store.settings.reminderEnabled },
                set: { store.setReminderEnabled($0) }
            ))
            .tint(LafoTheme.primary)

            DatePicker("提醒时间", selection: Binding(
                get: { store.reminderDateForPicker() },
                set: { store.updateReminderTime($0) }
            ), displayedComponents: .hourAndMinute)

            Picker("通知显示模式", selection: Binding(
                get: { store.settings.notificationDisplayMode },
                set: { store.updateNotificationDisplayMode($0) }
            )) {
                ForEach(NotificationDisplayMode.allCases) { mode in
                    Text(mode.displayText).tag(mode)
                }
            }

            Text(notificationModeHelp)
                .font(.footnote)
                .foregroundStyle(LafoTheme.mutedText)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var notificationModeHelp: String {
        switch store.settings.notificationDisplayMode {
        case .cute:
            return "可爱模式会使用 Lafo 风格文案，但不会包含具体记录内容。"
        case .privateMode:
            return "隐私模式不会出现敏感词，适合锁屏展示。"
        case .minimal:
            return "极简模式只显示非常短的中性提醒。"
        }
    }

    private var petCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("伙伴名字")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            TextField("Lafo 小肠肠", text: $petNameDraft)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    store.renamePet(petNameDraft)
                    petNameDraft = store.settings.petName
                }

            Button("保存名字") {
                store.renamePet(petNameDraft)
                petNameDraft = store.settings.petName
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("数据管理")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            ShareLink(item: store.exportCSVText()) {
                Label("导出 CSV", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())

            Button(role: .destructive) {
                showingClearAlert = true
            } label: {
                Label("清空本地数据", systemImage: "trash.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GhostButtonStyle())

            Text("记录默认保存在本机。导出后文件由你自行保管。")
                .font(.footnote)
                .foregroundStyle(LafoTheme.mutedText)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var policyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("说明")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            ForEach(LegalDocument.allCases) { document in
                NavigationLink {
                    LegalDocumentView(document: document)
                } label: {
                    HStack {
                        Text(document.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(LafoTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(LafoTheme.mutedText)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }
}

private enum LegalDocument: String, CaseIterable, Identifiable {
    case privacy
    case terms
    case medicalDisclaimer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy:
            return "隐私政策"
        case .terms:
            return "用户协议"
        case .medicalDisclaimer:
            return "医疗免责声明"
        }
    }

    var body: String {
        switch self {
        case .privacy:
            return "Lafo 不要求注册或登录，记录默认仅保存在设备本地，不上传排便记录，不接入第三方广告追踪，不使用 HealthKit，不出售、出租或交换用户数据。你可以随时导出或清空本地数据。"
        case .terms:
            return "请用 Lafo 做个人生活记录。你应自行保管设备和导出的文件，避免把私密内容分享给不希望看到的人。"
        case .medicalDisclaimer:
            return "Lafo 仅用于个人生活记录和习惯观察，不提供医学诊断、治疗建议、疾病判断或医疗服务。若你持续感到身体不适，请及时咨询专业医生。"
        }
    }
}

private struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ZStack {
            LafoTheme.page.ignoresSafeArea()

            ScrollView {
                Text(document.body)
                    .font(.body)
                    .foregroundStyle(LafoTheme.text)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .modifier(LafoTheme.cardShadow())
                    .padding(16)
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
