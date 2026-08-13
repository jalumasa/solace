import SwiftUI

/// A soft, blurred, slowly morphing multi-color backdrop used behind every
/// top-level screen. Liquid Glass surfaces refract whatever sits behind
/// them, so a flat white background leaves glass looking flat and
/// colorless — this gives it something vivid and alive to bend instead.
struct AmbientBackground: View {
    let colors: [Color]

    var body: some View {
        TimelineView(.animation) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: Self.meshPoints(at: timeline.date),
                colors: colors
            )
        }
        .opacity(0.55)
        .blur(radius: 60)
        .ignoresSafeArea()
    }

    /// Corners stay pinned so the gradient always fully covers the screen;
    /// the four edge-midpoints and the center drift independently on their
    /// own sine waves for a slow, organic "gooey" wobble rather than a
    /// static gradient.
    private static func meshPoints(at date: Date) -> [SIMD2<Float>] {
        let t = Float(date.timeIntervalSinceReferenceDate)
        return [
            [0, 0],
            wobble([0.5, 0], phase: 0, amplitude: 0.12, t: t),
            [1, 0],
            wobble([0, 0.5], phase: 2.1, amplitude: 0.12, t: t),
            wobble([0.5, 0.5], phase: 4.2, amplitude: 0.16, t: t),
            wobble([1, 0.5], phase: 1.3, amplitude: 0.12, t: t),
            [0, 1],
            wobble([0.5, 1], phase: 3.4, amplitude: 0.12, t: t),
            [1, 1]
        ]
    }

    private static func wobble(_ base: SIMD2<Float>, phase: Float, amplitude: Float, t: Float) -> SIMD2<Float> {
        let dx = sin(t * 0.35 + phase) * amplitude
        let dy = cos(t * 0.3 + phase * 1.7) * amplitude
        return SIMD2(
            min(max(base.x + dx, 0), 1),
            min(max(base.y + dy, 0), 1)
        )
    }
}
