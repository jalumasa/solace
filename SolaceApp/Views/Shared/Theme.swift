import SwiftUI
import SolaceCore

/// Shared visual language for the redesigned app: a small, consistent set of
/// colors, spacing, and corner-radius values so Liquid Glass surfaces read as
/// one system rather than being styled ad hoc per screen. Liquid Glass reads
/// best over colorful, dynamic content — flat white behind it looks dull —
/// so every top-level screen sits on an `AmbientBackground` rather than a
/// plain system background.
enum Theme {
    /// Primary brand accent — carried over from the original leaf mark.
    static let primary = Color.teal

    /// Secondary calming tone used on the Today and Games surfaces to
    /// differentiate "reflective" screens from the primary teal used for
    /// core actions (messaging, resources).
    static let secondary = Color(red: 0.62, green: 0.58, blue: 0.94) // soft lavender

    /// Warm tone reserved for streaks/encouragement, never for errors.
    static let warm = Color(red: 0.98, green: 0.71, blue: 0.42)

    /// A small rotating accent palette for iconography — quick-action tiles,
    /// game rows — so the app reads as lively rather than monochrome.
    static let coral = Color(red: 0.98, green: 0.45, blue: 0.42)
    static let sky = Color(red: 0.35, green: 0.68, blue: 0.98)
    static let leaf = Color(red: 0.40, green: 0.78, blue: 0.55)
    static let sun = Color(red: 0.98, green: 0.76, blue: 0.24)

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }

    enum Radius {
        /// Standard card corner radius, tuned to feel concentric with
        /// device corners at typical card insets.
        static let card: CGFloat = 24
        static let control: CGFloat = 16
    }

    /// Per-tab ambient gradient palettes (see `AmbientBackground`) — each
    /// tab gets its own gentle identity rather than one flat background.
    enum Ambient {
        static let today: [Color] = [sun, coral, warm, secondary, primary, sky, warm, coral, sun]
        static let talk: [Color] = [sky, primary, secondary, primary, sky, secondary, secondary, sky, primary]
        static let wellness: [Color] = [leaf, primary, sky, primary, leaf, secondary, sky, leaf, primary]
        static let games: [Color] = [secondary, coral, sun, primary, secondary, leaf, sun, secondary, coral]
        static let profile: [Color] = [primary, secondary, sky, secondary, primary, leaf, sky, primary, secondary]
    }
}

public extension MoodLevel {
    /// UI-layer color mapping — kept out of `SolaceCore` since that package
    /// has no SwiftUI dependency.
    var color: Color {
        switch self {
        case .awful: return Theme.coral
        case .bad: return Theme.warm
        case .okay: return Theme.sun
        case .good: return Theme.leaf
        case .great: return Theme.primary
        }
    }
}
