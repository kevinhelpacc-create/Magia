import Foundation

enum HapticStyle: String, Codable, CaseIterable, Identifiable, Hashable {
    case light, medium, heavy, success, warning, error

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: return "Ligera"
        case .medium: return "Media"
        case .heavy: return "Fuerte"
        case .success: return "Éxito"
        case .warning: return "Aviso"
        case .error: return "Error"
        }
    }
}

/// A single instruction inside a `Routine`. Swift auto-synthesizes
/// `Codable`/`Hashable` for enums with associated values as long as every
/// associated value conforms, so no manual encode/decode code is needed.
enum RoutineAction: Codable, Hashable {
    case tap(digit: Int)
    case wait(seconds: Double)
    case showMessage(text: String)
    case playSound(name: String)
    case vibrate(style: HapticStyle)
    case runSequence(routineID: UUID)
}

extension RoutineAction {
    var summary: String {
        switch self {
        case .tap(let digit):
            return "Pulsar \(digit)"
        case .wait(let seconds):
            return "Esperar \(formatted(seconds))s"
        case .showMessage(let text):
            return text.isEmpty ? "Mostrar mensaje" : "Mostrar mensaje: \"\(text)\""
        case .playSound(let name):
            return name.isEmpty ? "Reproducir sonido" : "Reproducir sonido: \(name)"
        case .vibrate(let style):
            return "Vibrar (\(style.displayName))"
        case .runSequence:
            return "Ejecutar subrutina"
        }
    }

    var iconName: String {
        switch self {
        case .tap: return "circle.grid.3x3.fill"
        case .wait: return "clock"
        case .showMessage: return "text.bubble"
        case .playSound: return "speaker.wave.2"
        case .vibrate: return "iphone.radiowaves.left.and.right"
        case .runSequence: return "arrow.triangle.branch"
        }
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
