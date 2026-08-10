import Foundation

public struct User: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var email: String
    public var displayName: String
    public var role: Role
    public var bio: String?
    public var createdAt: Date

    public init(
        id: String,
        email: String,
        displayName: String,
        role: Role,
        bio: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.bio = bio
        self.createdAt = createdAt
    }
}
