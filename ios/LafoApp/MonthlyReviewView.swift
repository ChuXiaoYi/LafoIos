import SwiftUI
import UIKit

struct MonthlyReviewView: View {
    let review: MonthlyReview

    @Environment(\.dismiss) private var dismiss
    @State private var imageURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.page.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        MonthlyReviewCardView(review: review)
                            .padding(.horizontal, 18)

                        privacyHint
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("月度小报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundStyle(LafoTheme.forest)
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionBar
            }
        }
    }

    private var privacyHint: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(LafoTheme.forest)
                .frame(width: 24, height: 24)
                .background(LafoTheme.paleGreen)
                .clipShape(Circle())

            Text("月度报告只展示轻量统计，不包含备注、具体记录列表或精确敏感内容。")
                .font(.footnote)
                .foregroundStyle(LafoTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 18)
    }

    private var actionBar: some View {
        VStack(spacing: 10) {
            Button {
                imageURL = renderCardImage()
            } label: {
                Label("生成图片", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())

            if let imageURL {
                ShareLink(item: imageURL) {
                    Label("保存 / 分享图片", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    @MainActor
    private func renderCardImage() -> URL? {
        let renderer = ImageRenderer(content: MonthlyReviewCardView(review: review).frame(width: 360, height: 450))
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage,
              let data = image.pngData()
        else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("lafo-monthly-review.png")
        do {
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            #if DEBUG
            print("Lafo 月报图片生成失败：\(error.localizedDescription)")
            #endif
            return nil
        }
    }
}

struct MonthlyReviewCardView: View {
    let review: MonthlyReview

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lafo")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(LafoTheme.textStrong)
                    Text(review.month.formatted(.dateTime.year().month(.wide)))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(LafoTheme.mutedText)
                }

                Spacer()

                Text("🌱")
                    .font(.system(size: 44))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(review.title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LafoTheme.forest)
                Text("这是本月的小肚肚节奏回顾，只做生活记录参考。")
                    .font(.footnote)
                    .foregroundStyle(LafoTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                cardMetric(title: "记录天数", value: "\(review.recordedDays) 天", icon: "🗓️")
                cardMetric(title: "总次数", value: "\(review.totalPoopCount) 次", icon: "✨")
                cardMetric(title: "常见状态", value: review.mostCommonType?.label ?? "暂无", icon: review.mostCommonType?.icon ?? "☁️")
                cardMetric(title: "常见时间", value: review.mostCommonTimeBucket?.label ?? "暂无", icon: "🕘")
            }

            Text("Lafo，让每一次轻松都有记录。")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LafoTheme.brown)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }

    private func cardMetric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .padding(14)
        .background(LafoTheme.warmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
