import Foundation
import Combine

/// Simple on-device JSON persistence for the magician's saved routines.
/// A singleton (`shared`) so both the normal SwiftUI views and the
/// App Intents extension point (Shortcuts) read/write the same data.
@MainActor
final class RoutineStore: ObservableObject {
    static let shared = RoutineStore()

    @Published private(set) var routines: [Routine] = []

    private let fileURL: URL

    init(fileName: String = "routines.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(fileName)
        load()
        if routines.isEmpty {
            routines = [.example]
            save()
        }
    }

    func routine(withID id: UUID) -> Routine? {
        routines.first { $0.id == id }
    }

    func add(_ routine: Routine) {
        routines.append(routine)
        save()
    }

    func update(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        var updated = routine
        updated.updatedAt = Date()
        routines[index] = updated
        save()
    }

    func delete(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        save()
    }

    func duplicate(_ routine: Routine) {
        var copy = routine
        copy.id = UUID()
        copy.name = routine.name + " (copia)"
        copy.createdAt = Date()
        copy.updatedAt = Date()
        routines.append(copy)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
            routines = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(routines) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
