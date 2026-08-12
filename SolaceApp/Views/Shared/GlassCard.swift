import SwiftUI

extension View {
    /// Wraps content in a Liquid Glass card using the shared corner radius.
    /// For multiple adjacent glass cards (e.g. a quick-action grid), wrap
    /// them together in `GlassCardContainer` — glass surfaces can't sample
    /// other glass, so nearby glass elements need to share a
    /// `GlassEffectContainer` to blend and light correctly.
    func glassCard(cornerRadius: CGFloat = Theme.Radius.card) -> some View {
        self
            .padding(Theme.Spacing.medium)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Groups multiple glass cards (e.g. the Today quick-action grid) so they
/// render, blend, and animate together as one Liquid Glass system.
struct GlassCardContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        GlassEffectContainer {
            content
        }
    }
}
