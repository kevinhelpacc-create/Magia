import Foundation
import Combine

/// Bridges an App Intent (triggered from Shortcuts, Back Tap, or the
/// Action Button) into the running app: the intent just records which
/// routine was requested, and `RoutineListView` observes this to present
/// `PerformanceView` and auto-start playback — no in-app tap needed at all.
@MainActor
final class PerformanceLauncher: ObservableObject {
    static let shared = PerformanceLauncher()

    @Published var pendingRoutineID: UUID?

    func request(routineID: UUID) {
        pendingRoutineID = routineID
    }
}
