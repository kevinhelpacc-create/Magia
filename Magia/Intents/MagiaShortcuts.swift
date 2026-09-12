import AppIntents

/// Donates `RunRoutineIntent` to the system so it shows up in the
/// Shortcuts app, in Siri suggestions, and as an assignable action for
/// Back Tap / the Action Button.
struct MagiaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RunRoutineIntent(),
            phrases: [
                "Ejecuta una rutina en \(.applicationName)",
                "Inicia \(.applicationName)",
            ],
            shortTitle: "Ejecutar rutina",
            systemImageName: "wand.and.stars"
        )
    }
}
