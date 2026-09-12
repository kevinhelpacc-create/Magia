import SwiftUI

/// The full-screen stage the spectator actually looks at: background,
/// keypad, optional message overlay, the invisible trigger zone, and the
/// final reveal. Everything here lives inside our own view hierarchy.
struct PerformanceView: View {
    let routine: Routine
    var autoStart: Bool = false

    @StateObject private var player = SequencePlayer()
    @EnvironmentObject private var store: RoutineStore

    var body: some View {
        ZStack {
            background

            VStack {
                if let message = player.currentMessage {
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(routine.appearance.accentColor)
                        .padding(.top, 60)
                        .transition(.opacity)
                } else {
                    Color.clear.frame(height: 1).padding(.top, 60)
                }

                Spacer()

                LockKeypadView(
                    theme: routine.appearance,
                    enteredCount: player.enteredDigits.count,
                    highlightedKey: player.highlightedKey,
                    onKeyTapped: nil
                )

                Spacer()
                Spacer()
            }
            .animation(.easeInOut(duration: 0.25), value: player.currentMessage)

            SecretTriggerOverlay {
                if player.isRunning {
                    player.stop()
                } else {
                    player.start(routine)
                }
            }
        }
        .statusBarHidden()
        .onAppear {
            player.attach(store: store)
            if autoStart {
                player.start(routine)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { player.isFinished },
            set: { isPresented in if !isPresented { player.reset() } }
        )) {
            FinalScreenView(config: routine.finalScreen) {
                player.reset()
            }
        }
    }

    private var background: some View {
        Group {
            switch routine.appearance.backgroundKind {
            case .solidColor:
                routine.appearance.primaryColor
            case .gradient:
                LinearGradient(
                    colors: [routine.appearance.primaryColor, routine.appearance.secondaryColor],
                    startPoint: .top, endPoint: .bottom
                )
            case .systemLike:
                LinearGradient(
                    colors: [routine.appearance.primaryColor, routine.appearance.primaryColor.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}
