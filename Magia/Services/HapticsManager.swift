import CoreHaptics
import UIKit

/// Thin wrapper around haptic feedback. Uses `UIFeedbackGenerator` for the
/// built-in styles (reliable, no authoring needed); the `CHHapticEngine` is
/// started and kept around so you can extend `play(_:)` with custom
/// `CHHapticPattern`s (e.g. a slow "searching" rumble) if you want a more
/// theatrical effect for a given routine.
final class HapticsManager {
    private var engine: CHHapticEngine?

    init() {
        let supportsHaptics = CHHapticEngine.capabilities(forHardware: .init()).supportsHaptics
        guard supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    func play(_ style: HapticStyle) {
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
