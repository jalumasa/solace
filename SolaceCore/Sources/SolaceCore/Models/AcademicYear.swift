import Foundation

public enum AcademicYear: String, Codable, Sendable, CaseIterable, Equatable {
    case freshman
    case sophomore
    case junior
    case senior
    case graduate

    public var label: String {
        switch self {
        case .freshman: return "Freshman"
        case .sophomore: return "Sophomore"
        case .junior: return "Junior"
        case .senior: return "Senior"
        case .graduate: return "Graduate"
        }
    }
}
