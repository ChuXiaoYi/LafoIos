import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LafoStore

    var body: some View {
        Group {
            if store.privacyAccepted {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .background(LafoTheme.page.ignoresSafeArea())
    }
}

private struct WelcomeView: View {
    @EnvironmentObject private var store: LafoStore

    var body: some View {
        ZStack {
            LafoTheme.page.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    Spacer(minLength: 36)

                    VStack(spacing: 12) {
                        Text("🌱")
                            .font(.system(size: 64))
                            .frame(width: 118, height: 118)
                            .background(LafoTheme.softGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                        Text("Lafo")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(LafoTheme.textStrong)

                        Text("让每一次轻松都有记录")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(LafoTheme.brown)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        infoRow(icon: "lock.fill", title: "默认本地保存", body: "第一版不需要登录，也不会把你的记录上传到服务器。")
                        infoRow(icon: "heart.fill", title: "温柔记录", body: "Lafo 只帮你观察生活节奏，不打分、不吓人。")
                        infoRow(icon: "cross.case.fill", title: "不是医疗工具", body: "Lafo 不提供诊断、治疗建议或医疗服务。持续不适请咨询专业医生。")
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .modifier(LafoTheme.cardShadow())

                    Button {
                        store.acceptPrivacy()
                    } label: {
                        Text("开始记录")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Text("点击开始表示你已了解：Lafo 仅用于个人生活记录和习惯观察。")
                        .font(.footnote)
                        .foregroundStyle(LafoTheme.mutedText)
                        .multilineTextAlignment(.center)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private func infoRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(LafoTheme.forest)
                .frame(width: 30, height: 30)
                .background(LafoTheme.paleGreen)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LafoTheme.text)
                Text(body)
                    .font(.footnote)
                    .foregroundStyle(LafoTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("今日", systemImage: "house.fill")
                }

            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }

            StatsView()
                .tabItem {
                    Label("趋势", systemImage: "chart.bar.fill")
                }

            BuddyView()
                .tabItem {
                    Label("伙伴", systemImage: "face.smiling.fill")
                }

            SettingsView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(LafoTheme.forest)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 15)
            .background(configuration.isPressed ? LafoTheme.forest : LafoTheme.primary)
            .clipShape(Capsule())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(LafoTheme.deepGreen)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? LafoTheme.paleGreen.opacity(0.72) : LafoTheme.paleGreen)
            .clipShape(Capsule())
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.62))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(configuration.isPressed ? Color.black.opacity(0.08) : Color.black.opacity(0.04))
            .clipShape(Capsule())
    }
}
