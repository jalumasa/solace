import Foundation

/// A topic-based peer support group. Circles are curated/seeded, not
/// user-created — any signed-in student or counselor can browse, join, and
/// post.
public struct SupportCircle: Identifiable, Codable, Sendable, Equatable, Hashable {
    public let id: String
    public var name: String
    public var topicDescription: String
    public var memberIDs: [String]
    public var createdAt: Date

    public init(
        id: String,
        name: String,
        topicDescription: String,
        memberIDs: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.topicDescription = topicDescription
        self.memberIDs = memberIDs
        self.createdAt = createdAt
    }

    public func isMember(_ userID: String) -> Bool {
        memberIDs.contains(userID)
    }
}
