import SwiftUI

/// Builds a routine: reorderable list of steps, plus links to its
/// appearance and final-screen settings.
struct RoutineEditorView: View {
    @EnvironmentObject private var store: RoutineStore
    @State private var routine: Routine
    @State private var editingStep: RoutineStep?
    @State private var isAddingStep = false
    @State private var isPresentingPerformance = false

    init(routine: Routine) {
        _routine = State(initialValue: routine)
    }

    var body: some View {
        Form {
            Section("Nombre") {
                TextField("Nombre de la rutina", text: $routine.name)
                    .onChange(of: routine.name) { _, _ in save() }
            }

            Section("Pasos") {
                ForEach(routine.steps) { step in
                    Button {
                        editingStep = step
                    } label: {
                        HStack {
                            Image(systemName: step.action.iconName)
                                .frame(width: 24)
                            Text(step.action.summary)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .onMove(perform: moveSteps)
                .onDelete(perform: deleteSteps)

                Button {
                    isAddingStep = true
                } label: {
                    Label("Añadir paso", systemImage: "plus.circle")
                }
            }

            Section("Apariencia y final") {
                NavigationLink("Apariencia del teclado") {
                    AppearanceSettingsView(appearance: $routine.appearance, onChange: save)
                }
                NavigationLink("Pantalla final") {
                    FinalScreenEditorView(config: $routine.finalScreen, onChange: save)
                }
            }

            Section {
                Button {
                    isPresentingPerformance = true
                } label: {
                    Label("Probar rutina", systemImage: "play.fill")
                }
            }
        }
        .navigationTitle(routine.name)
        .toolbar { EditButton() }
        .sheet(item: $editingStep) { step in
            ActionEditorView(
                step: step,
                availableRoutines: store.routines.filter { $0.id != routine.id }
            ) { updated in
                if let index = routine.steps.firstIndex(where: { $0.id == step.id }) {
                    routine.steps[index] = updated
                    save()
                }
            }
        }
        .sheet(isPresented: $isAddingStep) {
            ActionEditorView(
                step: nil,
                availableRoutines: store.routines.filter { $0.id != routine.id }
            ) { newStep in
                routine.steps.append(newStep)
                save()
            }
        }
        .fullScreenCover(isPresented: $isPresentingPerformance) {
            PerformanceView(routine: routine)
                .environmentObject(store)
        }
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        routine.steps.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func deleteSteps(at offsets: IndexSet) {
        routine.steps.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        store.update(routine)
    }
}
