import Foundation
import Observation

/// Drives the Worry Jar calming activity: write down a worry, then let it
/// go. No history is kept and nothing is judged — only a gentle running
/// count of how many worries have been released this session, so there's
/// something to see without turning it into a scored game.
@MainActor
@Observable
public final class WorryJarViewModel {
    public var draftText: String = ""
    public private(set) var releasedCount = 0
    public private(set) var isReleasing = false

    public init() {}

    public var canRelease: Bool {
        !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isReleasing
    }

    /// Starts the release animation. The caller drives the actual visual
    /// transition and calls `finishRelease()` once it completes.
    public func release() {
        guard canRelease else { return }
        isReleasing = true
    }

    public func finishRelease() {
        guard isReleasing else { return }
        releasedCount += 1
        draftText = ""
        isReleasing = false
    }
}
