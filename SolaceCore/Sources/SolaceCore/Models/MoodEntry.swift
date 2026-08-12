import Foundation

public enum MoodLevel: Int, Codable, Sendable, CaseIterable, Comparable {
    case awful = 1
    case bad = 2
    case okay = 3
    case good = 4
    case great = 5

    public static func < (lhs: MoodLevel, rhs: MoodLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var label: String {
        switch self {
        case .awful: return "Awful"
        case .bad: return "Bad"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    public var emoji: String {
        switch self {
        case .awful: return "😞"
        case .bad: return "🙁"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }
}

public struct MoodEntry: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var mood: MoodLevel
    public var note: String?
    public var createdAt: Date

    public init(id: String, mood: MoodLevel, note: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.mood = mood
        self.note = note
        self.createdAt = createdAt
    }
}
