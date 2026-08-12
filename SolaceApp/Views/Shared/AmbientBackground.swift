import SwiftUI

/// A soft, blurred multi-color backdrop used behind every top-level screen.
/// Liquid Glass surfaces refract whatever sits behind them, so a flat white
/// background leaves glass looking flat and colorless — this gives it
/// something vivid and alive to bend instead.
struct AmbientBackground: View {
    let colors: [Color]

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: colors
        )
        .opacity(0.55)
        .blur(radius: 60)
        .ignoresSafeArea()
    }
}
