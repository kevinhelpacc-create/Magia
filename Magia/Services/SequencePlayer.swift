import Foundation
import Combine

/// The routine's state machine. It never synthesizes a real touch event or
/// talks to any system input API (no VoiceControl, no AssistiveTouch, no
/// UIEvent injection) — it only mutates `@Published` state that
/// `LockKeypadView` reacts to with ordinary SwiftUI animations. That is
/// exactly why iOS never draws an accessibility tap indicator for it: as
/// far as the system is concerned, nothing "pressed" anything.
@MainActor
final class SequencePlayer: ObservableObject {
    @Published private(set) var enteredDigits: [Int] = []
    @Published private(set) var highlightedKey: Int? = nil
    @Published private(set) var currentMessage: String? = nil
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isFinished: Bool = false

    private var runTask: Task<Void, Never>?
    private let haptics = HapticsManager()
    private let sounds = SoundManager()
    private weak var store: RoutineStore?

    func attach(store: RoutineStore) {
        self.store = store
    }

    func start(_ routine: Routine) {
        stop()
        reset()
        isRunning = true
        runTask = Task { [weak self] in
            guard let self else { return }
            await self.execute(steps: routine.steps)
            self.isRunning = false
            self.isFinished = true
        }
    }

    func stop() {
        runTask?.cancel()
        runTask = nil
        isRunning = false
    }

    func reset() {
        enteredDigits = []
        highlightedKey = nil
        currentMessage = nil
        isFinished = false
    }

    private func execute(steps: [RoutineStep], depth: Int = 0) async {
        guard depth < 8 else { return } // guards against a runSequence cycle
        for step in steps {
            if Task.isCancelled { return }
            await perform(step.action, depth: depth)
        }
    }

    private func perform(_ action: RoutineAction, depth: Int) async {
        switch action {
        case .tap(let digit):
            await pressKey(digit)
        case .wait(let seconds):
            try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
        case .showMessage(let text):
            currentMessage = text
        case .playSound(let name):
            sounds.play(named: name)
        case .vibrate(let style):
            haptics.play(style)
        case .runSequence(let routineID):
            if let nested = store?.routine(withID: routineID) {
                await execute(steps: nested.steps, depth: depth + 1)
            }
        }
    }

    /// Drives the visual press: highlight the key, register the digit a
    /// beat later, then release the highlight — timed to read as a natural
    /// tap rather than an instantaneous state change.
    private func pressKey(_ digit: Int) async {
        highlightedKey = digit
        haptics.play(.light)
        try? await Task.sleep(nanoseconds: 140_000_000)
        enteredDigits.append(digit)
        try? await Task.sleep(nanoseconds: 120_000_000)
        highlightedKey = nil
    }
}
