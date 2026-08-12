import Foundation

public struct GratitudeEntry: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var text: String
    public var createdAt: Date

    public init(id: String, text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
