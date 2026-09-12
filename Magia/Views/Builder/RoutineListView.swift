import SwiftUI

/// The app's root screen: every saved routine, with quick actions to
/// perform, edit, duplicate, or delete it.
struct RoutineListView: View {
    @EnvironmentObject private var store: RoutineStore
    @StateObject private var launcher = PerformanceLauncher.shared

    @State private var performingRoutine: Routine?
    @State private var launcherAutoStart = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.routines) { routine in
                    NavigationLink(value: routine.id) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name).font(.headline)
                            Text("\(routine.steps.count) pasos")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(routine)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                        Button {
                            store.duplicate(routine)
                        } label: {
                            Label("Duplicar", systemImage: "doc.on.doc")
                        }
                        .tint(.blue)
                        Button {
                            launcherAutoStart = false
                            performingRoutine = routine
                        } label: {
                            Label("Actuar", systemImage: "play.fill")
                        }
                        .tint(.green)
                    }
                }
            }
            .navigationTitle("Rutinas")
            .navigationDestination(for: UUID.self) { id in
                if let routine = store.routine(withID: id) {
                    RoutineEditorView(routine: routine)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.add(Routine())
                    } label: {
                        Label("Nueva rutina", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if store.routines.isEmpty {
                    ContentUnavailableView(
                        "Sin rutinas",
                        systemImage: "wand.and.stars",
                        description: Text("Crea tu primera rutina con el botón +")
                    )
                }
            }
        }
        .fullScreenCover(item: $performingRoutine, onDismiss: { launcherAutoStart = false }) { routine in
            PerformanceView(routine: routine, autoStart: launcherAutoStart)
                .environmentObject(store)
        }
        .onReceive(launcher.$pendingRoutineID) { id in
            guard let id, let routine = store.routine(withID: id) else { return }
            launcherAutoStart = true
            performingRoutine = routine
            launcher.pendingRoutineID = nil
        }
    }
}
