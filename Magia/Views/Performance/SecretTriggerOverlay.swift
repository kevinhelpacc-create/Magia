import SwiftUI

/// A transparent, edge-anchored hot zone the magician can press to
/// start/stop the routine while holding the phone naturally.
///
/// This is an ordinary SwiftUI gesture recognizer inside our own view
/// hierarchy — not a system-level input synthesis, VoiceControl action, or
/// AssistiveTouch gesture — so iOS draws no accessibility tap indicator
/// around it. Long-press was chosen over a plain tap so an accidental
/// brush from the magician's grip doesn't fire the routine early.
struct SecretTriggerOverlay: View {
    let action: () -> Void
    @GestureState private var isPressing = false

    var body: some View {
        VStack {
            HStack {
                Color.clear
                    .frame(width: 64, height: 64)
                    .contentShape(Rectangle())
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .updating($isPressing) { value, state, _ in state = value }
                            .onEnded { _ in action() }
                    )
                Spacer()
            }
            Spacer()
        }
    }
}
