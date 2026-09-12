import SwiftUI

/// A generic circular numeric pad with a growing dot indicator — the same
/// family of UI used by countless passcode/PIN screens (banking apps,
/// device-lock screens, etc.), styled here through `AppearanceTheme` rather
/// than by reproducing Apple's actual lock screen artwork.
///
/// `onKeyTapped` is `nil` during a performance: the pad is purely a display
/// surface driven by `SequencePlayer`, so a spectator's own taps do nothing.
struct LockKeypadView: View {
    let theme: AppearanceTheme
    let enteredCount: Int
    let highlightedKey: Int?
    let onKeyTapped: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 36) {
            dotsIndicator
            keypadGrid
        }
        .padding(.horizontal, 32)
    }

    private var dotsIndicator: some View {
        HStack(spacing: 14) {
            if enteredCount == 0 {
                // Reserves the row's height before any digit is entered,
                // so the keypad doesn't jump down on the first tap.
                Circle().fill(Color.clear).frame(width: 12, height: 12)
            }
            ForEach(0..<enteredCount, id: \.self) { _ in
                Circle().fill(theme.accentColor).frame(width: 12, height: 12)
            }
        }
        .frame(minHeight: 12)
        .animation(.easeOut(duration: 0.2), value: enteredCount)
    }

    private var keypadGrid: some View {
        VStack(spacing: 22) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 22) {
                    ForEach(1...3, id: \.self) { col in
                        keyButton(row * 3 + col)
                    }
                }
            }
            HStack(spacing: 22) {
                Color.clear.frame(width: 84, height: 84)
                keyButton(0)
                Color.clear.frame(width: 84, height: 84)
            }
        }
    }

    private func keyButton(_ digit: Int) -> some View {
        let isHighlighted = highlightedKey == digit
        return Button {
            onKeyTapped?(digit)
        } label: {
            Text("\(digit)")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(theme.accentColor)
                .frame(width: 84, height: 84)
                .background(
                    Circle().fill(theme.secondaryColor.opacity(isHighlighted ? 0.9 : 0.35))
                )
                .scaleEffect(isHighlighted ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(onKeyTapped != nil)
        .animation(.easeOut(duration: 0.12), value: isHighlighted)
    }
}
