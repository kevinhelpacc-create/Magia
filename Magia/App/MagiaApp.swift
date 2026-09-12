import SwiftUI

@main
struct MagiaApp: App {
    @StateObject private var store = RoutineStore.shared

    var body: some Scene {
        WindowGroup {
            RoutineListView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
