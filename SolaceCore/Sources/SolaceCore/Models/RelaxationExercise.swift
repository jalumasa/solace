import Foundation

/// A single phase in a breathing exercise, in seconds.
public struct BreathingPattern: Codable, Sendable, Equatable {
    public var inhale: TimeInterval
    public var hold: TimeInterval
    public var exhale: TimeInterval
    public var holdAfterExhale: TimeInterval

    public init(inhale: TimeInterval, hold: TimeInterval, exhale: TimeInterval, holdAfterExhale: TimeInterval) {
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.holdAfterExhale = holdAfterExhale
    }

    /// Classic 4-7-8 relaxation breathing pattern.
    public static let fourSevenEight = BreathingPattern(inhale: 4, hold: 7, exhale: 8, holdAfterExhale: 0)

    /// Box breathing, commonly used for quick stress relief.
    public static let box = BreathingPattern(inhale: 4, hold: 4, exhale: 4, holdAfterExhale: 4)
}

public enum RelaxationKind: Sendable, Equatable {
    case breathing(BreathingPattern)
    case groundingScript(steps: [String])
}

public struct RelaxationExercise: Identifiable, Sendable, Equatable {
    public let id: String
    public var title: String
    public var description: String
    public var kind: RelaxationKind

    public init(id: String, title: String, description: String, kind: RelaxationKind) {
        self.id = id
        self.title = title
        self.description = description
        self.kind = kind
    }

    public static let breathingExercises: [RelaxationExercise] = [
        RelaxationExercise(
            id: "box-breathing",
            title: "Box Breathing",
            description: "A steady four-count pattern used to calm the nervous system quickly.",
            kind: .breathing(.box)
        ),
        RelaxationExercise(
            id: "four-seven-eight",
            title: "4-7-8 Breathing",
            description: "A longer exhale pattern that promotes deep relaxation before sleep.",
            kind: .breathing(.fourSevenEight)
        )
    ]

    public static let groundingExercises: [RelaxationExercise] = [
        RelaxationExercise(
            id: "five-four-three-two-one",
            title: "5-4-3-2-1 Grounding",
            description: "A sensory grounding technique for moments of acute anxiety.",
            kind: .groundingScript(steps: [
                "Name 5 things you can see around you.",
                "Name 4 things you can touch or feel.",
                "Name 3 things you can hear.",
                "Name 2 things you can smell.",
                "Name 1 thing you can taste."
            ])
        )
    ]
}
