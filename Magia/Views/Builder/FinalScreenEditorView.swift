import SwiftUI

/// Lets the magician customize the reveal screen shown after a routine
/// completes.
struct FinalScreenEditorView: View {
    @Binding var config: FinalScreenConfig
    var onChange: () -> Void

    var body: some View {
        Form {
            Section("Contenido") {
                TextField("Título", text: $config.title)
                TextField("Subtítulo", text: $config.subtitle)
                TextField("Símbolo SF Symbol", text: $config.symbolName)
            }
            Section("Colores") {
                ColorPicker("Fondo", selection: Binding(
                    get: { Color(hex: config.backgroundHex) },
                    set: { config.backgroundHex = $0.toHex() }
                ))
                ColorPicker("Acento", selection: Binding(
                    get: { Color(hex: config.accentHex) },
                    set: { config.accentHex = $0.toHex() }
                ))
            }
            Section("Cierre") {
                Toggle("Cierre automático", isOn: Binding(
                    get: { config.autoDismissAfter != nil },
                    set: { config.autoDismissAfter = $0 ? 4 : nil }
                ))
                if let value = config.autoDismissAfter {
                    Stepper(
                        String(format: "Después de %.1f s", value),
                        value: Binding(
                            get: { config.autoDismissAfter ?? 4 },
                            set: { config.autoDismissAfter = $0 }
                        ),
                        in: 1...20, step: 0.5
                    )
                }
            }
        }
        .navigationTitle("Pantalla final")
        .onDisappear(perform: onChange)
    }
}
