import Foundation

/// A saved trick: an ordered list of steps plus its own look and its own
/// final reveal screen, so each routine can be dressed differently.
struct Routine: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var steps: [RoutineStep]
    var appearance: AppearanceTheme
    var finalScreen: FinalScreenConfig
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "Nueva rutina",
        steps: [RoutineStep] = [],
        appearance: AppearanceTheme = .default,
        finalScreen: FinalScreenConfig = FinalScreenConfig(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.steps = steps
        self.appearance = appearance
        self.finalScreen = finalScreen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Mirrors the example sequence from the routine spec: 1 · 8 · 2 · 0 · 0 · 4
    /// with the requested waits, so the app is demoable on first launch.
    static let example = Routine(
        name: "Fecha de cumpleaños",
        steps: [
            RoutineStep(action: .tap(digit: 1)),
            RoutineStep(action: .wait(seconds: 5)),
            RoutineStep(action: .tap(digit: 8)),
            RoutineStep(action: .wait(seconds: 5)),
            RoutineStep(action: .tap(digit: 2)),
            RoutineStep(action: .wait(seconds: 3)),
            RoutineStep(action: .tap(digit: 0)),
            RoutineStep(action: .wait(seconds: 1)),
            RoutineStep(action: .tap(digit: 0)),
            RoutineStep(action: .wait(seconds: 3)),
            RoutineStep(action: .tap(digit: 4)),
        ],
        finalScreen: FinalScreenConfig(title: "¡Es tu fecha!", subtitle: "18/02/2004")
    )
}
