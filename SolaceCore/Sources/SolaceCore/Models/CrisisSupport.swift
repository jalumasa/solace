import Foundation

/// Static, always-available crisis resources shown alongside the AI chatbot and
/// resource library. The chatbot is for general emotional support only — it is
/// not equipped to handle active crises, so these contacts must stay visible
/// and not depend on any network call.
public struct CrisisContact: Identifiable, Sendable, Equatable {
    public let id: String
    public var name: String
    public var detail: String

    public init(id: String, name: String, detail: String) {
        self.id = id
        self.name = name
        self.detail = detail
    }
}

public enum CrisisSupport {
    public static let contacts: [CrisisContact] = [
        CrisisContact(id: "988", name: "988 Suicide & Crisis Lifeline", detail: "Call or text 988 (US) — available 24/7"),
        CrisisContact(id: "crisis-text-line", name: "Crisis Text Line", detail: "Text HOME to 741741 (US) — available 24/7")
    ]
}
