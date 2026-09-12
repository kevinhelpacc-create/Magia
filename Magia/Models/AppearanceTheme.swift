import SwiftUI

/// Visual configuration for the performance screen. Deliberately generic
/// (a numeric passcode pad is a common UI pattern, not exclusive to iOS)
/// so it can be restyled per routine without cloning Apple's real lock
/// screen artwork.
struct AppearanceTheme: Codable, Hashable {
    enum BackgroundKind: String, Codable, CaseIterable, Identifiable, Hashable {
        case solidColor, gradient, systemLike

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .solidColor: return "Color sólido"
            case .gradient: return "Degradado"
            case .systemLike: return "Estilo pantalla de bloqueo"
            }
        }
    }

    var backgroundKind: BackgroundKind = .systemLike
    var primaryColorHex: String = "#0B0B0F"
    var secondaryColorHex: String = "#2C2C34"
    var accentColorHex: String = "#FFFFFF"
    var showClock: Bool = true

    var primaryColor: Color { Color(hex: primaryColorHex) }
    var secondaryColor: Color { Color(hex: secondaryColorHex) }
    var accentColor: Color { Color(hex: accentColorHex) }

    static let `default` = AppearanceTheme()
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        guard cleaned.count == 6 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }

        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
