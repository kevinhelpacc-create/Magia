import SwiftUI

/// Lets the magician restyle the keypad screen per routine.
struct AppearanceSettingsView: View {
    @Binding var appearance: AppearanceTheme
    var onChange: () -> Void

    var body: some View {
        Form {
            Picker("Fondo", selection: $appearance.backgroundKind) {
                ForEach(AppearanceTheme.BackgroundKind.allCases) { kind in
                    Text(kind.displayName).tag(kind)
                }
            }
            ColorPicker("Color principal", selection: Binding(
                get: { appearance.primaryColor },
                set: { appearance.primaryColorHex = $0.toHex() }
            ))
            ColorPicker("Color secundario", selection: Binding(
                get: { appearance.secondaryColor },
                set: { appearance.secondaryColorHex = $0.toHex() }
            ))
            ColorPicker("Color de acento", selection: Binding(
                get: { appearance.accentColor },
                set: { appearance.accentColorHex = $0.toHex() }
            ))
            Toggle("Mostrar reloj", isOn: $appearance.showClock)
        }
        .navigationTitle("Apariencia")
        .onDisappear(perform: onChange)
    }
}
