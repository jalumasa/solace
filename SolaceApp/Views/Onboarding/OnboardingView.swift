import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
    let colors: [Color]
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        title: "Welcome to Solace",
        message: "A quieter corner of your day, made just for you.",
        systemImage: "leaf.fill",
        colors: Theme.Ambient.today
    ),
    OnboardingPage(
        title: "Check in with yourself",
        message: "One tap a day to track how you're feeling and watch your streak grow.",
        systemImage: "face.smiling.fill",
        colors: Theme.Ambient.profile
    ),
    OnboardingPage(
        title: "Talk, any time",
        message: "Chat with an AI companion 24/7, or message a real counselor when you're ready.",
        systemImage: "bubble.left.and.bubble.right.fill",
        colors: Theme.Ambient.talk
    ),
    OnboardingPage(
        title: "Small moments of calm",
        message: "Breathing exercises, a gratitude garden, and a few playful games — no pressure, ever.",
        systemImage: "sparkles",
        colors: Theme.Ambient.games
    )
]

/// A one-time, swipeable welcome carousel shown before sign-in on first
/// launch. `AuthRootView` gates this behind `hasCompletedOnboarding` in
/// `@AppStorage`, so returning users skip straight to `SignInView`.
struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var pageIndex = 0

    private var isLastPage: Bool { pageIndex == onboardingPages.count - 1 }

    var body: some View {
        ZStack {
            AmbientBackground(colors: onboardingPages[pageIndex].colors)
                .animation(.easeInOut(duration: 0.8), value: pageIndex)

            VStack(spacing: 0) {
                TabView(selection: $pageIndex) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: Theme.Spacing.large) {
                    HStack(spacing: 8) {
                        ForEach(onboardingPages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == pageIndex ? Color.primary : Color.primary.opacity(0.25))
                                .frame(width: index == pageIndex ? 22 : 8, height: 8)
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pageIndex)

                    Button {
                        if isLastPage {
                            onFinish()
                        } else {
                            withAnimation { pageIndex += 1 }
                        }
                    } label: {
                        Text(isLastPage ? "Get Started" : "Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.horizontal, Theme.Spacing.xLarge)

                    Button("Skip") { onFinish() }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .opacity(isLastPage ? 0 : 1)
                }
                .padding(.bottom, Theme.Spacing.large)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()

            Image(systemName: page.systemImage)
                .font(.system(size: 52))
                .foregroundStyle(Theme.primary)
                .frame(width: 140, height: 140)
                .glassEffect(.regular, in: Circle())

            VStack(spacing: Theme.Spacing.small) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(page.message)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xLarge)
            }

            Spacer()
            Spacer()
        }
    }
}
