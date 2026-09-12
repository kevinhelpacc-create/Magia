import SwiftUI

/// Add or edit a single `RoutineAction` inside a routine.
struct ActionEditorView: View {
    enum Kind: String, CaseIterable, Identifiable, Hashable {
        case tap, wait, showMessage, playSound, vibrate, runSequence

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .tap: return "Pulsar número"
            case .wait: return "Esperar"
            case .showMessage: return "Mostrar mensaje"
            case .playSound: return "Reproducir sonido"
            case .vibrate: return "Vibrar"
            case .runSequence: return "Ejecutar subrutina"
            }
        }
    }

    let existingStepID: UUID?
    let availableRoutines: [Routine]
    let onSave: (RoutineStep) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var kind: Kind
    @State private var digit: Int
    @State private var seconds: Double
    @State private var message: String
    @State private var soundName: String
    @State private var hapticStyle: HapticStyle
    @State private var selectedRoutineID: UUID?

    init(step: RoutineStep?, availableRoutines: [Routine], onSave: @escaping (RoutineStep) -> Void) {
        self.existingStepID = step?.id
        self.availableRoutines = availableRoutines
        self.onSave = onSave

        var initialKind: Kind = .tap
        var initialDigit = 0
        var initialSeconds = 1.0
        var initialMessage = ""
        var initialSoundName = ""
        var initialHapticStyle: HapticStyle = .light
        var initialRoutineID: UUID?

        switch step?.action {
        case .tap(let d):
            initialKind = .tap; initialDigit = d
        case .wait(let s):
            initialKind = .wait; initialSeconds = s
        case .showMessage(let text):
            initialKind = .showMessage; initialMessage = text
        case .playSound(let name):
            initialKind = .playSound; initialSoundName = name
        case .vibrate(let style):
            initialKind = .vibrate; initialHapticStyle = style
        case .runSequence(let id):
            initialKind = .runSequence; initialRoutineID = id
        case .none:
            break
        }

        _kind = State(initialValue: initialKind)
        _digit = State(initialValue: initialDigit)
        _seconds = State(initialValue: initialSeconds)
        _message = State(initialValue: initialMessage)
        _soundName = State(initialValue: initialSoundName)
        _hapticStyle = State(initialValue: initialHapticStyle)
        _selectedRoutineID = State(initialValue: initialRoutineID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Tipo de acción", selection: $kind) {
                    ForEach(Kind.allCases) { k in
                        Text(k.displayName).tag(k)
                    }
                }

                switch kind {
                case .tap:
                    Stepper("Número: \(digit)", value: $digit, in: 0...9)
                case .wait:
                    Stepper(String(format: "Esperar %.1f s", seconds), value: $seconds, in: 0...60, step: 0.5)
                case .showMessage:
                    TextField("Texto del mensaje", text: $message)
                case .playSound:
                    TextField("Nombre del archivo de sonido", text: $soundName)
                case .vibrate:
                    Picker("Intensidad", selection: $hapticStyle) {
                        ForEach(HapticStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                case .runSequence:
                    Picker("Subrutina", selection: $selectedRoutineID) {
                        Text("Ninguna").tag(UUID?.none)
                        ForEach(availableRoutines) { r in
                            Text(r.name).tag(Optional(r.id))
                        }
                    }
                }
            }
            .navigationTitle(existingStepID == nil ? "Añadir paso" : "Editar paso")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(RoutineStep(id: existingStepID ?? UUID(), action: buildAction()))
                        dismiss()
                    }
                }
            }
        }
    }

    private func buildAction() -> RoutineAction {
        switch kind {
        case .tap: return .tap(digit: digit)
        case .wait: return .wait(seconds: seconds)
        case .showMessage: return .showMessage(text: message)
        case .playSound: return .playSound(name: soundName)
        case .vibrate: return .vibrate(style: hapticStyle)
        case .runSequence: return .runSequence(routineID: selectedRoutineID ?? UUID())
        }
    }
}
