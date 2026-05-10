import SwiftUI

enum LafoTheme {
    static let page = Color(hex: 0xFFF8E8)
    static let homePage = Color(hex: 0xF7F2E8)
    static let card = Color.white
    static let primary = Color(hex: 0x65B96F)
    static let deepGreen = Color(hex: 0x347D40)
    static let forest = Color(hex: 0x2F6F39)
    static let text = Color(hex: 0x23211D)
    static let textStrong = Color(hex: 0x2B2B2B)
    static let brown = Color(hex: 0x57410B)
    static let amberText = Color(hex: 0x8A5D00)
    static let selected = Color(hex: 0xFFF4C9)
    static let highlight = Color(hex: 0xFFE68A)
    static let softGreen = Color(hex: 0xF1F8EC)
    static let paleGreen = Color(hex: 0xF0F8EC)
    static let warmCard = Color(hex: 0xFFFAF0)
    static let mutedText = Color.black.opacity(0.52)

    static func cardShadow() -> some ViewModifier {
        ShadowModifier()
    }
}

private struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(red: 0.26, green: 0.20, blue: 0.08).opacity(0.06), radius: 14, x: 0, y: 7)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
