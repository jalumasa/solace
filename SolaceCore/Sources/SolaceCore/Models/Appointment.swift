import Foundation

public enum AppointmentStatus: String, Codable, Sendable, CaseIterable, Equatable {
    case pending
    case confirmed
    case declined
    case cancelled
}

public struct Appointment: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: String
    public var studentID: String
    public var studentName: String
    public var counselorID: String
    public var counselorName: String
    public var scheduledAt: Date
    public var status: AppointmentStatus
    public var createdAt: Date

    public init(
        id: String,
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date,
        status: AppointmentStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.studentID = studentID
        self.studentName = studentName
        self.counselorID = counselorID
        self.counselorName = counselorName
        self.scheduledAt = scheduledAt
        self.status = status
        self.createdAt = createdAt
    }

    public var participantIDs: [String] { [studentID, counselorID] }

    public func otherParticipantName(currentUserID: String) -> String {
        currentUserID == studentID ? counselorName : studentName
    }
}
