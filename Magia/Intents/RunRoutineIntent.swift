import AppIntents

/// The Shortcuts action a magician binds to a discreet physical trigger —
/// Back Tap, the Action Button, or a Siri phrase. It only opens *this* app
/// and asks it to play one of its own saved routines; it never touches the
/// real iOS lock screen, another app, or any system security mechanism.
struct RunRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "Ejecutar rutina de Magia"
    static var description = IntentDescription(
        "Abre Magia y reproduce la rutina seleccionada en la pantalla de actuación."
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Rutina")
    var routine: RoutineEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        PerformanceLauncher.shared.request(routineID: routine.id)
        return .result()
    }
}
