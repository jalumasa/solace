import Foundation

public struct Conversation: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public var studentID: String
    public var studentName: String
    public var counselorID: String
    public var counselorName: String
    public var lastMessageText: String?
    public var lastMessageAt: Date?
    public var createdAt: Date

    public init(
        id: String,
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        lastMessageText: String? = nil,
        lastMessageAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.studentID = studentID
        self.studentName = studentName
        self.counselorID = counselorID
        self.counselorName = counselorName
        self.lastMessageText = lastMessageText
        self.lastMessageAt = lastMessageAt
        self.createdAt = createdAt
    }

    public var participantIDs: [String] { [studentID, counselorID] }

    public func otherParticipantName(currentUserID: String) -> String {
        currentUserID == studentID ? counselorName : studentName
    }
}
