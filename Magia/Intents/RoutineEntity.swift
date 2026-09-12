import AppIntents

/// Exposes each saved `Routine` to the Shortcuts app as a pickable entity,
/// so a Shortcut (bound to Back Tap, the Action Button, Siri, or the
/// Shortcuts app itself) can name exactly which routine to run.
struct RoutineEntity: AppEntity {
    let id: UUID
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Rutina"
    static var defaultQuery = RoutineEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct RoutineEntityQuery: EntityQuery {
    func entities(for identifiers: [RoutineEntity.ID]) async throws -> [RoutineEntity] {
        let store = await RoutineStore.shared
        return await MainActor.run {
            store.routines
                .filter { identifiers.contains($0.id) }
                .map { RoutineEntity(id: $0.id, name: $0.name) }
        }
    }

    func suggestedEntities() async throws -> [RoutineEntity] {
        let store = await RoutineStore.shared
        return await MainActor.run {
            store.routines.map { RoutineEntity(id: $0.id, name: $0.name) }
        }
    }
}
