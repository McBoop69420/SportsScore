import Foundation

enum SidebarFilter: Hashable, Equatable {
    case live
    case today
    case tomorrow
    case all
    case sport(Sport)

    var displayName: String {
        switch self {
        case .live:
            return "Live"
        case .today:
            return "Today"
        case .tomorrow:
            return "Tomorrow"
        case .all:
            return "All Sports"
        case .sport(let sport):
            return sport.displayName
        }
    }

    var icon: String {
        switch self {
        case .live:
            return "livephoto"
        case .today:
            return "calendar"
        case .tomorrow:
            return "calendar.badge.clock"
        case .all:
            return "sportscourt.fill"
        case .sport(let sport):
            return sport.sfSymbol
        }
    }
}
