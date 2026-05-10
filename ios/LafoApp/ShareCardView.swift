import SwiftUI

struct ShareCardView: View {
    let record: PoopRecord

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Lafo")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(LafoTheme.text)
                Spacer()
                Text("🌱")
                    .font(.title)
            }

            VStack(spacing: 8) {
                Text(record.poopType.icon)
                    .font(.system(size: 52))
                Text(record.poopType.cuteLine)
                    .font(.title3.bold())
                    .foregroundStyle(LafoTheme.text)
                    .multilineTextAlignment(.center)
                Text("轻松记一下，慢慢看规律")
                    .font(.footnote)
                    .foregroundStyle(LafoTheme.mutedText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(LafoTheme.selected)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("Lafo，让每一次轻松都有记录")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LafoTheme.brown)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .modifier(LafoTheme.cardShadow())
    }
}
