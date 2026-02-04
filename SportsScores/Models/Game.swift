import Foundation

struct Game: Identifiable, Codable, Hashable {
    let id: String
    let league: League
    let homeTeam: Team
    let awayTeam: Team
    let homeScore: Int?
    let awayScore: Int?
    let status: GameStatus
    let startTime: Date
    let venue: String?
    let broadcast: String?
    let statusDetail: String?

    var isLive: Bool {
        status == .inProgress || status == .halftime || status == .delayed
    }

    var isUpcoming: Bool {
        status == .scheduled
    }

    var isCompleted: Bool {
        status == .final
    }

    var displayTime: String {
        if isLive {
            return statusDetail ?? "LIVE"
        } else if isCompleted {
            return "Final"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: startTime)
        }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(startTime) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(startTime) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: startTime)
        }
    }
}

struct Team: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let abbreviation: String
    let displayName: String
    let logoURL: URL?
    let color: String?
    let alternateColor: String?
    let record: String?
    let rank: Int?

    var primaryColor: String {
        color ?? "666666"
    }

    /// Returns a color suitable for display - uses alternate color if primary is too dark
    var displayColor: String {
        let primary = primaryColor.lowercased()

        // Check if the primary color is black, near-black, or grey
        if isColorTooDark(hex: primary) {
            return alternateColor ?? "666666"
        }
        return primary
    }

    private func isColorTooDark(hex: String) -> Bool {
        // Parse hex color
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let hexInt = UInt64(hexSanitized, radix: 16) else {
            return false
        }

        let r = Double((hexInt >> 16) & 0xFF) / 255.0
        let g = Double((hexInt >> 8) & 0xFF) / 255.0
        let b = Double(hexInt & 0xFF) / 255.0

        // Calculate relative luminance
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b

        // Consider colors with luminance < 0.25 as too dark
        return luminance < 0.25
    }

    var isRanked: Bool {
        rank != nil
    }
}

enum GameStatus: String, Codable {
    case scheduled = "STATUS_SCHEDULED"
    case inProgress = "STATUS_IN_PROGRESS"
    case halftime = "STATUS_HALFTIME"
    case final = "STATUS_FINAL"
    case postponed = "STATUS_POSTPONED"
    case canceled = "STATUS_CANCELED"
    case delayed = "STATUS_DELAYED"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = GameStatus(rawValue: value) ?? .unknown
    }

    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "Live"
        case .halftime: return "Halftime"
        case .final: return "Final"
        case .postponed: return "Postponed"
        case .canceled: return "Canceled"
        case .delayed: return "Delayed"
        case .unknown: return "Unknown"
        }
    }

    var isActive: Bool {
        switch self {
        case .inProgress, .halftime, .delayed:
            return true
        default:
            return false
        }
    }
}
