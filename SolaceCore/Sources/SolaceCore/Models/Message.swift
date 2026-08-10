import Foundation

public struct Message: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var conversationID: String
    public var senderID: String
    public var text: String
    public var sentAt: Date

    public init(
        id: String,
        conversationID: String,
        senderID: String,
        text: String,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.sentAt = sentAt
    }
}
