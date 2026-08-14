import Foundation

public struct User: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var email: String
    public var displayName: String
    public var role: Role
    public var bio: String?
    /// Student-only academic details. Always nil for counselors.
    public var major: String?
    public var academicYear: AcademicYear?
    public var age: Int?
    public var createdAt: Date

    public init(
        id: String,
        email: String,
        displayName: String,
        role: Role,
        bio: String? = nil,
        major: String? = nil,
        academicYear: AcademicYear? = nil,
        age: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.bio = bio
        self.major = major
        self.academicYear = academicYear
        self.age = age
        self.createdAt = createdAt
    }
}
