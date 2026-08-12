import Foundation
import Observation

/// Drives the Bubble Pop calming activity: a grid of bubbles that pop and
/// stay popped. No score, no fail state, no timer — resetting is always the
/// user's choice, never forced.
@MainActor
@Observable
public final class BubblePopViewModel {
    public let columns: Int
    public let rows: Int
    public private(set) var poppedIndices: Set<Int> = []

    public init(columns: Int = 5, rows: Int = 6) {
        self.columns = columns
        self.rows = rows
    }

    public var bubbleCount: Int { columns * rows }

    public var isComplete: Bool { poppedIndices.count == bubbleCount }

    public func isPopped(_ index: Int) -> Bool {
        poppedIndices.contains(index)
    }

    public func pop(at index: Int) {
        guard index >= 0, index < bubbleCount else { return }
        poppedIndices.insert(index)
    }

    public func reset() {
        poppedIndices.removeAll()
    }
}
