import Foundation

/// Wraps a `RoutineAction` with a stable identity so it can be listed,
/// reordered, and edited in SwiftUI.
struct RoutineStep: Identifiable, Codable, Hashable {
    let id: UUID
    var action: RoutineAction

    init(id: UUID = UUID(), action: RoutineAction) {
        self.id = id
        self.action = action
    }
}
