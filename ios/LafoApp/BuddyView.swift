import SwiftUI

struct BuddyView: View {
    @EnvironmentObject private var store: LafoStore

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.page.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        buddyHero
                        progressCard
                        unlockedStates
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("伙伴")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var buddyHero: some View {
        VStack(spacing: 16) {
            Text(store.petMoodIcon)
                .font(.system(size: 78))
                .frame(width: 142, height: 142)
                .background(LafoTheme.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))

            VStack(spacing: 6) {
                Text(store.settings.petName)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LafoTheme.textStrong)
                Text("Lv.\(buddyLevel)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LafoTheme.forest)
            }

            Text(store.buddyMessage)
                .font(.subheadline)
                .foregroundStyle(LafoTheme.mutedText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("陪伴进度")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            HStack(spacing: 12) {
                smallMetric(title: "轻松能量", value: "\(store.petProgress.totalEnergy)")
                smallMetric(title: "连续记录", value: "\(store.stats.streakDays) 天")
            }

            ProgressView(value: Double(store.petProgress.totalEnergy % 40), total: 40)
                .tint(LafoTheme.primary)
            Text("每次记录都会给 Lafo 一点轻松能量，停几天也不会扣分。")
                .font(.caption)
                .foregroundStyle(LafoTheme.mutedText)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var unlockedStates: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("已解锁状态")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                stateTile(icon: "😊", title: "开心", unlocked: store.records.count >= 1)
                stateTile(icon: "🌱", title: "鼓励", unlocked: true)
                stateTile(icon: "☁️", title: "新表情", unlocked: store.petProgress.unlockedExpressionIDs.contains("streak_3"))
                stateTile(icon: "🎉", title: "小装饰", unlocked: store.petProgress.unlockedDecorationIDs.contains("week_crown"))
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var buddyLevel: Int {
        max(1, min(9, store.petProgress.totalEnergy / 40 + 1))
    }

    private func smallMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(LafoTheme.mutedText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LafoTheme.warmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func stateTile(icon: String, title: String, unlocked: Bool) -> some View {
        VStack(spacing: 8) {
            Text(unlocked ? icon : "🔒")
                .font(.title)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LafoTheme.text)
            Text(unlocked ? "已解锁" : "继续陪伴")
                .font(.caption)
                .foregroundStyle(LafoTheme.mutedText)
        }
        .frame(maxWidth: .infinity, minHeight: 112)
        .background(unlocked ? LafoTheme.softGreen : Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
