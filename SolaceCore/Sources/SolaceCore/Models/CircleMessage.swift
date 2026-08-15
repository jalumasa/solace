import Foundation

public struct CircleMessage: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var circleID: String
    public var senderID: String
    public var senderName: String
    public var text: String
    public var sentAt: Date

    public init(
        id: String,
        circleID: String,
        senderID: String,
        senderName: String,
        text: String,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.circleID = circleID
        self.senderID = senderID
        self.senderName = senderName
        self.text = text
        self.sentAt = sentAt
    }
}
