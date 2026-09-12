import SwiftUI

/// The reveal shown after the last step of a routine plays out.
struct FinalScreenView: View {
    let config: FinalScreenConfig
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(hex: config.backgroundHex).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: config.symbolName)
                    .font(.system(size: 72))
                    .foregroundStyle(Color(hex: config.accentHex))
                Text(config.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                if !config.subtitle.isEmpty {
                    Text(config.subtitle)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
        .task {
            guard let delay = config.autoDismissAfter else { return }
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            onDismiss()
        }
    }
}
