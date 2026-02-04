import Foundation

enum Sport: String, CaseIterable, Identifiable, Codable {
    case football
    case basketball
    case baseball
    case hockey
    case soccer
    case racing
    case tennis
    case golf

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .football: return "Football"
        case .basketball: return "Basketball"
        case .baseball: return "Baseball"
        case .hockey: return "Hockey"
        case .soccer: return "Soccer"
        case .racing: return "Racing"
        case .tennis: return "Tennis"
        case .golf: return "Golf"
        }
    }

    var sfSymbol: String {
        switch self {
        case .football: return "football.fill"
        case .basketball: return "basketball.fill"
        case .baseball: return "baseball.fill"
        case .hockey: return "hockey.puck.fill"
        case .soccer: return "soccerball"
        case .racing: return "flag.checkered"
        case .tennis: return "tennis.racket"
        case .golf: return "figure.golf"
        }
    }

    var leagues: [League] {
        switch self {
        case .football: return [.nfl, .collegeFootball]
        case .basketball: return [.nba, .wnba, .collegeBasketball]
        case .baseball: return [.mlb]
        case .hockey: return [.nhl]
        case .soccer: return [.premierLeague, .laLiga, .mls, .championsLeague]
        case .racing: return [.f1]
        case .tennis: return [.atp, .wta]
        case .golf: return [.pga]
        }
    }
}

enum League: String, CaseIterable, Identifiable, Codable {
    // Football
    case nfl
    case collegeFootball = "college-football"

    // Basketball
    case nba
    case wnba
    case collegeBasketball = "mens-college-basketball"

    // Baseball
    case mlb

    // Hockey
    case nhl

    // Soccer
    case premierLeague = "eng.1"
    case laLiga = "esp.1"
    case mls = "usa.1"
    case championsLeague = "uefa.champions"

    // Racing
    case f1

    // Tennis
    case atp
    case wta

    // Golf
    case pga

    var id: String { rawValue }

    var sport: Sport {
        switch self {
        case .nfl, .collegeFootball: return .football
        case .nba, .wnba, .collegeBasketball: return .basketball
        case .mlb: return .baseball
        case .nhl: return .hockey
        case .premierLeague, .laLiga, .mls, .championsLeague: return .soccer
        case .f1: return .racing
        case .atp, .wta: return .tennis
        case .pga: return .golf
        }
    }

    var displayName: String {
        switch self {
        case .nfl: return "NFL"
        case .collegeFootball: return "College Football"
        case .nba: return "NBA"
        case .wnba: return "WNBA"
        case .collegeBasketball: return "College Basketball"
        case .mlb: return "MLB"
        case .nhl: return "NHL"
        case .premierLeague: return "Premier League"
        case .laLiga: return "La Liga"
        case .mls: return "MLS"
        case .championsLeague: return "Champions League"
        case .f1: return "Formula 1"
        case .atp: return "ATP Tour"
        case .wta: return "WTA Tour"
        case .pga: return "PGA Tour"
        }
    }

    var espnSport: String {
        switch self {
        case .nfl, .collegeFootball: return "football"
        case .nba, .wnba, .collegeBasketball: return "basketball"
        case .mlb: return "baseball"
        case .nhl: return "hockey"
        case .premierLeague, .laLiga, .mls, .championsLeague: return "soccer"
        case .f1: return "racing"
        case .atp, .wta: return "tennis"
        case .pga: return "golf"
        }
    }

    var espnLeague: String {
        switch self {
        case .nfl: return "nfl"
        case .collegeFootball: return "college-football"
        case .nba: return "nba"
        case .wnba: return "wnba"
        case .collegeBasketball: return "mens-college-basketball"
        case .mlb: return "mlb"
        case .nhl: return "nhl"
        case .premierLeague: return "eng.1"
        case .laLiga: return "esp.1"
        case .mls: return "usa.1"
        case .championsLeague: return "uefa.champions"
        case .f1: return "f1"
        case .atp: return "atp"
        case .wta: return "wta"
        case .pga: return "pga"
        }
    }
}
