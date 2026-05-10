import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: LafoStore
    @State private var showingMonthlyReview = false

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.homePage.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard
                        monthlyReviewEntry
                        statsGrid
                        weekMiniChart
                        gentleTip
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("趋势")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingMonthlyReview) {
                MonthlyReviewView(review: store.monthlyReview())
                    .presentationDetents([.large])
                    .presentationCornerRadius(28)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("本周肠肠小结")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(LafoTheme.textStrong)

            Text(summaryText)
                .font(.subheadline)
                .foregroundStyle(LafoTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(title: "今日", value: "\(store.stats.todayCount) 次", icon: "🌱")
            metricCard(title: "本周", value: "\(store.stats.weekCount) 次", icon: "📅")
            metricCard(title: "周均", value: String(format: "%.1f 次/天", store.stats.weekAverage), icon: "📊")
            metricCard(title: "连续", value: "\(store.stats.streakDays) 天", icon: "🏅")
            metricCard(title: "常见状态", value: store.stats.mostCommonType?.label ?? "暂无", icon: store.stats.mostCommonType?.icon ?? "☁️")
            metricCard(title: "常见时间", value: store.stats.mostCommonTimeBucket?.label ?? "暂无", icon: "🕘")
            metricCard(title: "本月记录", value: "\(store.stats.monthRecordedDays) 天", icon: "🗓️")
        }
    }

    private var monthlyReviewEntry: some View {
        Button {
            showingMonthlyReview = true
        } label: {
            HStack(spacing: 14) {
                Text("🗓️")
                    .font(.title)
                    .frame(width: 54, height: 54)
                    .background(LafoTheme.selected)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("查看本月小肚肚报告")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(LafoTheme.text)
                    Text("只展示轻量统计，不包含备注和具体敏感内容。")
                        .font(.caption)
                        .foregroundStyle(LafoTheme.mutedText)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LafoTheme.forest)
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .modifier(LafoTheme.cardShadow())
        }
        .buttonStyle(.plain)
    }

    private var weekMiniChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("近 7 天")
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(lastSevenDays, id: \.self) { day in
                    let count = store.summary(for: day).poopCount
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(count > 0 ? LafoTheme.primary : Color.black.opacity(0.08))
                            .frame(height: CGFloat(max(8, count * 18)))
                        Text("\(Calendar.current.component(.day, from: day))")
                            .font(.caption2)
                            .foregroundStyle(LafoTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 96, alignment: .bottom)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private var gentleTip: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("💬")
                .font(.title2)
            Text("Lafo 的提示仅供生活参考，不作为医学建议。如果持续不舒服，建议咨询专业医生。")
                .font(.footnote)
                .foregroundStyle(LafoTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(LafoTheme.softGreen)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var summaryText: String {
        if store.records.isEmpty {
            return "最近记录还不多，从第一次轻松时刻开始就好。"
        }
        if store.stats.weekCount == 0 {
            return "最近记录看起来有点少，想起来再顺手点一下就好。"
        }
        if let bucket = store.stats.mostCommonTimeBucket {
            return "你的轻松时刻大多发生在\(bucket.label)。"
        }
        return "本周你的肠肠比较有自己的节奏。"
    }

    private var lastSevenDays: [Date] {
        let start = Calendar.current.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset - 6, to: start)
        }
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(icon)
                .font(.title2)
            Text(title)
                .font(.caption)
                .foregroundStyle(LafoTheme.mutedText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(LafoTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }
}
