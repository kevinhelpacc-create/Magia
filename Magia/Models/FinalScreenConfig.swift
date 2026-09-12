import Foundation

/// The screen shown once a routine finishes playing back its steps.
struct FinalScreenConfig: Codable, Hashable {
    var title: String = "¡Correcto!"
    var subtitle: String = ""
    var symbolName: String = "checkmark.circle.fill"
    var backgroundHex: String = "#0B0B0F"
    var accentHex: String = "#34C759"
    /// Seconds before the final screen dismisses itself. `nil` means the
    /// magician dismisses it manually with a tap.
    var autoDismissAfter: Double? = nil
}
