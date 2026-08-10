import Foundation

public enum ResourceCategory: String, Codable, Sendable, CaseIterable {
    case anxiety
    case stress
    case sleep
    case depression
    case general

    public var displayName: String {
        switch self {
        case .anxiety: return "Anxiety"
        case .stress: return "Stress"
        case .sleep: return "Sleep"
        case .depression: return "Depression"
        case .general: return "General Wellbeing"
        }
    }
}

public struct ResourceItem: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var title: String
    public var summary: String
    public var body: String
    public var category: ResourceCategory
    public var tags: [String]

    public init(
        id: String,
        title: String,
        summary: String,
        body: String,
        category: ResourceCategory,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.body = body
        self.category = category
        self.tags = tags
    }
}
