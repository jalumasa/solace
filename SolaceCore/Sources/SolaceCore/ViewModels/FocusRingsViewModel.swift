import Foundation
import Observation

public enum FocusRingPhase: Sendable, Equatable {
    /// Ring is expanding toward full bloom — not ready to tap yet.
    case growing
    /// Ring is fully bloomed — tap now.
    case ready
    /// Brief pause after a tap (or a missed window) before the next round.
    case settling
}

/// Drives the Focus Rings calm-attention activity: tap the ring when it
/// blooms. Deliberately has no internal timer — the view advances it via
/// `tick(deltaTime:)`, matching `BreathingSessionViewModel`'s pattern, which
/// keeps this fully synchronous and unit-testable. Missing the window isn't
/// a failure: `calmStreak` only ever goes up, never resets, so there's no
/// pressure or penalty — just a gentle record of successful taps.
@MainActor
@Observable
public final class FocusRingsViewModel {
    public private(set) var phase: FocusRingPhase = .growing
    public private(set) var progress: Double = 0
    public private(set) var calmStreak = 0
    public private(set) var isRunning = false

    private let growDuration: TimeInterval
    private let readyWindow: TimeInterval
    private let settleDuration: TimeInterval
    private var elapsedInPhase: TimeInterval = 0

    public init(growDuration: TimeInterval = 3, readyWindow: TimeInterval = 1.5, settleDuration: TimeInterval = 0.6) {
        self.growDuration = growDuration
        self.readyWindow = readyWindow
        self.settleDuration = settleDuration
    }

    public func start() { isRunning = true }
    public func pause() { isRunning = false }

    public func reset() {
        isRunning = false
        phase = .growing
        progress = 0
        elapsedInPhase = 0
        calmStreak = 0
    }

    public func tick(deltaTime: TimeInterval) {
        guard isRunning, deltaTime > 0 else { return }
        elapsedInPhase += deltaTime
        switch phase {
        case .growing:
            progress = min(elapsedInPhase / growDuration, 1)
            if elapsedInPhase >= growDuration {
                phase = .ready
                elapsedInPhase = 0
            }
        case .ready:
            if elapsedInPhase >= readyWindow {
                advanceToSettling()
            }
        case .settling:
            if elapsedInPhase >= settleDuration {
                phase = .growing
                progress = 0
                elapsedInPhase = 0
            }
        }
    }

    /// Registers a tap. Only counts while the ring is `.ready` — taps at any
    /// other time are simply ignored, not penalized.
    public func tap() {
        guard phase == .ready else { return }
        calmStreak += 1
        advanceToSettling()
    }

    private func advanceToSettling() {
        phase = .settling
        elapsedInPhase = 0
    }
}
