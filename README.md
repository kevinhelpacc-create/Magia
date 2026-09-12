# Magia — app de rutina de mentalismo para iPhone

App nativa (SwiftUI) que simula una pantalla de teclado numérico dentro de
su **propia interfaz** y reproduce, a partir de un único disparador, una
secuencia programada de pulsaciones/esperas/mensajes/sonidos/vibraciones.
Todo el efecto ocurre dentro de la app: no se desbloquea iOS de verdad, no
se introduce nada en la pantalla de bloqueo real, no se controla ninguna
otra app y no se evade Face ID/Touch ID ni ningún mecanismo de seguridad.

## Por qué no aparecen círculos de accesibilidad

El requisito clave era no usar Control por Voz (VoiceControl) ni
AssistiveTouch, porque iOS dibuja un indicador visual para esos gestos
sintéticos a nivel de sistema. La solución aquí es otra: `SequencePlayer`
(`Magia/Services/SequencePlayer.swift`) no simula ningún toque real — solo
cambia propiedades `@Published` (qué tecla está "resaltada", qué dígitos se
han "introducido") y `LockKeypadView` reacciona a esos cambios con
animaciones SwiftUI normales. Como no hay ningún evento de toque
sintetizado a nivel de sistema, iOS no tiene nada que resaltar.

## Estructura del proyecto

```
Magia/
  App/            MagiaApp.swift (punto de entrada @main)
  Models/         Routine, RoutineStep, RoutineAction, AppearanceTheme, FinalScreenConfig
  Services/       RoutineStore (persistencia), SequencePlayer (máquina de estados),
                  HapticsManager, SoundManager, PerformanceLauncher (puente con Atajos)
  Views/
    Performance/  PerformanceView, LockKeypadView, FinalScreenView, SecretTriggerOverlay
    Builder/      RoutineListView, RoutineEditorView, ActionEditorView,
                  AppearanceSettingsView, FinalScreenEditorView
  Intents/        RunRoutineIntent, RoutineEntity, MagiaShortcuts (App Intents / Atajos)
  Resources/Sounds/  coloca aquí tus archivos de audio
```

## Cómo montarlo en Xcode (este entorno no tiene Xcode/macOS)

1. En un Mac, abre Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**.
   - Interface: **SwiftUI**. Language: **Swift**. Nombre: `Magia`.
   - Target mínimo recomendado: **iOS 17** (usa `ContentUnavailableView`,
     `AppShortcutsProvider`, `EntityQuery`, `onChange` de dos parámetros).
2. Borra `ContentView.swift` y el `App.swift` que genera la plantilla.
3. Arrastra toda la carpeta `Magia/` (la de este repo, con sus subcarpetas
   `App`, `Models`, `Services`, `Views`, `Intents`, `Resources`) al
   navegador de proyecto de Xcode, marcando "Copy items if needed" y
   añadiéndola al target de la app.
4. Compila. `Core Haptics` y `AVFoundation` son frameworks del sistema, se
   enlazan solos al importarlos; no hace falta capacidad ni permiso extra
   en Info.plist para nada de lo incluido aquí (no se usa cámara,
   micrófono ni red).
5. (Opcional) añade tus archivos de sonido a `Resources/Sounds` y
   referencia el nombre exacto de archivo en un paso `PLAY_SOUND`.

## Uso durante la actuación

1. El mago abre Magia y entra en una rutina guardada (o la crea en el
   constructor).
2. Pulsa "Actuar" (o dispara la rutina de forma discreta, ver abajo).
3. Mientras sostiene el teléfono y hace gestos sobre la carta física, la
   app reproduce automáticamente la secuencia de TAP/WAIT/mensajes/sonido/
   vibración configurada.
4. Al terminar el último paso aparece la pantalla final personalizada.

## Disparadores discretos disponibles

1. **Zona invisible dentro de la app** (ya incluida): mantén pulsada la
   esquina superior izquierda ~0.6s (`SecretTriggerOverlay`). Es
   simplemente un `LongPressGesture` de SwiftUI sobre una vista
   transparente propia — no dispara ningún indicador de accesibilidad.
2. **Back Tap** (Ajustes ▸ Accesibilidad ▸ Tocar ▸ Tocar parte trasera):
   asigna "Doble/Triple toque" a un Atajo que ejecute la acción
   "Ejecutar rutina de Magia" eligiendo la rutina deseada. Un toque en la
   parte trasera del teléfono no dibuja ningún círculo en pantalla.
3. **Botón de Acción** (iPhone 15 Pro o superior): Ajustes ▸ Botón de
   Acción ▸ Atajo ▸ el mismo Atajo que en el punto anterior.
4. **Atajos / Siri**: la app dona la App Intent `RunRoutineIntent`
   (ver `Intents/MagiaShortcuts.swift`), así que también puedes crear el
   Atajo manualmente desde la app Atajos y asignarlo a cualquier
   automatización que permita iOS.

En los tres últimos casos, `PerformanceLauncher` recibe la petición,
`RoutineListView` presenta `PerformanceView` para esa rutina y la arranca
automáticamente (`autoStart: true`) — el mago no necesita ni tocar la
pantalla.

## Constructor de rutinas

Cada rutina (`Routine`) tiene un nombre, una lista ordenada de pasos
(`RoutineStep` → `RoutineAction`), una apariencia (`AppearanceTheme`) y una
pantalla final (`FinalScreenConfig`). Acciones soportadas:

- `TAP(digit)` — `.tap(digit:)`
- `WAIT(seconds)` — `.wait(seconds:)`
- `SHOW_MESSAGE(text)` — `.showMessage(text:)`
- `PLAY_SOUND(name)` — `.playSound(name:)`
- `VIBRATE(style)` — `.vibrate(style:)`
- `RUN_SEQUENCE(routineID)` — `.runSequence(routineID:)` (encadena otra
  rutina guardada)

El editor (`RoutineEditorView` + `ActionEditorView`) permite añadir,
reordenar, editar y eliminar pasos, cambiar la apariencia del teclado y
configurar la pantalla final, todo antes de la actuación. `RoutineStore`
persiste todo en un JSON en el sandbox de la app (Documents), así que las
rutinas sobreviven a cerrar la app.

## Notas de concurrencia (Swift 5 vs Swift 6 language mode)

`RoutineStore` y `SequencePlayer` están anotados `@MainActor`. Si Xcode
usa el modo de concurrencia estricta (Swift 6), es posible que el acceso a
`RoutineStore.shared` desde el `EntityQuery` de `Intents/RoutineEntity.swift`
te pida ajustar el `await` — ya está escrito así (`let store = await
RoutineStore.shared`), pero si tu versión de Xcode sugiere una variante
distinta, sigue el quick-fix del compilador; no cambia el diseño.

## Ideas de extensión (no incluidas)

- Sincronizar rutinas entre dispositivos del mago con CloudKit.
- Patrones de vibración personalizados con `CHHapticPattern` en
  `HapticsManager` (ahora mismo usa los estilos estándar de
  `UIFeedbackGenerator`, que son más que suficientes para la mayoría de
  rutinas).
- Complicación de Apple Watch como disparador adicional vía App Intent.

## Límites explícitos (por diseño)

- No se automatiza ni se introduce nada en la pantalla de bloqueo real de
  iOS.
- No se controla ninguna otra app.
- No se usa Control por Voz ni AssistiveTouch para generar taps.
- No se intenta evadir Face ID/Touch ID ni ningún mecanismo de seguridad
  de iOS.
