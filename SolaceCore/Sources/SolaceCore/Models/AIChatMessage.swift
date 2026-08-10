import Foundation

public enum AIChatRole: String, Codable, Sendable {
    case user
    case assistant
}

public struct AIChatMessage: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var role: AIChatRole
    public var text: String
    public var sentAt: Date

    public init(id: String = UUID().uuidString, role: AIChatRole, text: String, sentAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.sentAt = sentAt
    }
}
