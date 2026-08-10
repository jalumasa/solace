import Foundation
import Observation

public enum BreathingPhase: Sendable, Equatable {
    case inhale
    case hold
    case exhale
    case holdAfterExhale

    public func duration(for pattern: BreathingPattern) -> TimeInterval {
        switch self {
        case .inhale: return pattern.inhale
        case .hold: return pattern.hold
        case .exhale: return pattern.exhale
        case .holdAfterExhale: return pattern.holdAfterExhale
        }
    }

    public var label: String {
        switch self {
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        case .holdAfterExhale: return "Hold"
        }
    }
}

/// Drives a guided breathing session. Deliberately has no internal timer —
/// the view advances it via `tick(deltaTime:)` (e.g. from a `TimelineView` or
/// `Timer`), which keeps this fully synchronous and unit-testable.
@MainActor
@Observable
public final class BreathingSessionViewModel {
    public let pattern: BreathingPattern
    private let phaseSequence: [BreathingPhase]
    private var currentIndex = 0

    public private(set) var timeRemainingInPhase: TimeInterval
    public private(set) var completedCycles = 0
    public private(set) var isRunning = false

    public init(pattern: BreathingPattern) {
        self.pattern = pattern
        let allPhases: [BreathingPhase] = [.inhale, .hold, .exhale, .holdAfterExhale]
        let sequence = allPhases.filter { $0.duration(for: pattern) > 0 }
        self.phaseSequence = sequence.isEmpty ? [.inhale] : sequence
        self.timeRemainingInPhase = self.phaseSequence[0].duration(for: pattern)
    }

    public var phase: BreathingPhase { phaseSequence[currentIndex] }

    public func start() { isRunning = true }
    public func pause() { isRunning = false }

    public func reset() {
        isRunning = false
        completedCycles = 0
        currentIndex = 0
        timeRemainingInPhase = phase.duration(for: pattern)
    }

    public func tick(deltaTime: TimeInterval) {
        guard isRunning, deltaTime > 0 else { return }
        var remaining = deltaTime
        while remaining > 0 {
            if remaining < timeRemainingInPhase {
                timeRemainingInPhase -= remaining
                remaining = 0
            } else {
                remaining -= timeRemainingInPhase
                advanceToNextPhase()
            }
        }
    }

    private func advanceToNextPhase() {
        let wasLastPhase = currentIndex == phaseSequence.count - 1
        currentIndex = (currentIndex + 1) % phaseSequence.count
        timeRemainingInPhase = phase.duration(for: pattern)
        if wasLastPhase {
            completedCycles += 1
        }
    }
}
