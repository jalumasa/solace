import Foundation

/// Growth stage of the Gratitude Garden, derived purely from how many
/// entries someone has logged — no scoring, just gentle visual progress.
public enum GardenStage: String, Sendable, CaseIterable {
    case seed
    case sprout
    case bloom
    case flourishing

    public static func stage(forEntryCount count: Int) -> GardenStage {
        switch count {
        case 0...2: return .seed
        case 3...6: return .sprout
        case 7...14: return .bloom
        default: return .flourishing
        }
    }

    public var label: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .bloom: return "Bloom"
        case .flourishing: return "Flourishing Garden"
        }
    }

    public var description: String {
        switch self {
        case .seed: return "Plant your first gratitude to get started."
        case .sprout: return "Your garden is sprouting. Keep it going."
        case .bloom: return "Your garden is blooming beautifully."
        case .flourishing: return "A flourishing garden — look how far you've come."
        }
    }
}
