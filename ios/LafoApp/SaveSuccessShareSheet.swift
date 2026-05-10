import SwiftUI

struct SaveSuccessShareSheet: View {
    let record: PoopRecord
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LafoTheme.page.ignoresSafeArea()

                VStack(spacing: 18) {
                    Text(record.poopType.icon)
                        .font(.system(size: 58))
                        .frame(width: 112, height: 112)
                        .background(record.poopType.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

                    Text("Lafo 已经帮你记好啦！")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(LafoTheme.text)

                    ShareCardView(record: record)

                    Button("回到今日", action: onClose)
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding(20)
            }
            .navigationTitle("记录成功")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
