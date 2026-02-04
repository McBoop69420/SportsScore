import Foundation

// MARK: - ESPN API Response Models

struct ESPNScoreboardResponse: Codable {
    let events: [ESPNEvent]
}

struct ESPNEvent: Codable {
    let id: String
    let name: String
    let date: String
    let status: ESPNStatus
    let competitions: [ESPNCompetition]
}

struct ESPNStatus: Codable {
    let type: ESPNStatusType
}

struct ESPNStatusType: Codable {
    let id: String
    let name: String
    let state: String
    let completed: Bool
    let description: String?
    let detail: String?
    let shortDetail: String?
}

struct ESPNCompetition: Codable {
    let id: String
    let venue: ESPNVenue?
    let competitors: [ESPNCompetitor]
    let broadcasts: [ESPNBroadcast]?
}

struct ESPNVenue: Codable {
    let fullName: String?
    let city: String?
    let state: String?
}

struct ESPNCompetitor: Codable {
    let id: String
    let homeAway: String
    let score: String?
    let team: ESPNTeam
    let records: [ESPNRecord]?
    let curatedRank: ESPNCuratedRank?
}

struct ESPNCuratedRank: Codable {
    let current: Int?
}

struct ESPNTeam: Codable {
    let id: String
    let name: String
    let abbreviation: String
    let displayName: String
    let logo: String?
    let color: String?
    let alternateColor: String?
}

struct ESPNRecord: Codable {
    let summary: String
}

struct ESPNBroadcast: Codable {
    let names: [String]?
}

// MARK: - Response Parsing Extension

extension ESPNScoreboardResponse {
    func toGames(league: League) -> [Game] {
        events.compactMap { event -> Game? in
            guard let competition = event.competitions.first else { return nil }

            let homeCompetitor = competition.competitors.first { $0.homeAway == "home" }
            let awayCompetitor = competition.competitors.first { $0.homeAway == "away" }

            guard let home = homeCompetitor, let away = awayCompetitor else { return nil }

            let homeTeam = Team(
                id: home.team.id,
                name: home.team.name,
                abbreviation: home.team.abbreviation,
                displayName: home.team.displayName,
                logoURL: home.team.logo.flatMap { URL(string: $0) },
                color: home.team.color,
                alternateColor: home.team.alternateColor,
                record: home.records?.first?.summary,
                rank: parseRank(from: home.curatedRank)
            )

            let awayTeam = Team(
                id: away.team.id,
                name: away.team.name,
                abbreviation: away.team.abbreviation,
                displayName: away.team.displayName,
                logoURL: away.team.logo.flatMap { URL(string: $0) },
                color: away.team.color,
                alternateColor: away.team.alternateColor,
                record: away.records?.first?.summary,
                rank: parseRank(from: away.curatedRank)
            )

            let status = parseGameStatus(from: event.status.type)
            let parsedDate = parseDate(from: event.date)
            if parsedDate == nil {
                print("⚠️ Failed to parse date: \(event.date)")
            }
            let startTime = parsedDate ?? Date()

            let broadcast = competition.broadcasts?.first?.names?.first

            return Game(
                id: event.id,
                league: league,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                homeScore: Int(home.score ?? ""),
                awayScore: Int(away.score ?? ""),
                status: status,
                startTime: startTime,
                venue: competition.venue?.fullName,
                broadcast: broadcast,
                statusDetail: event.status.type.shortDetail
            )
        }
    }

    private func parseRank(from curatedRank: ESPNCuratedRank?) -> Int? {
        guard let rank = curatedRank?.current else { return nil }
        // ESPN uses 99 for unranked teams, so filter those out
        return rank < 99 ? rank : nil
    }

    private func parseGameStatus(from statusType: ESPNStatusType) -> GameStatus {
        switch statusType.state {
        case "pre":
            return .scheduled
        case "in":
            if statusType.name.lowercased().contains("halftime") {
                return .halftime
            }
            return .inProgress
        case "post":
            return .final
        default:
            if statusType.name.lowercased().contains("postponed") {
                return .postponed
            } else if statusType.name.lowercased().contains("canceled") {
                return .canceled
            } else if statusType.name.lowercased().contains("delayed") {
                return .delayed
            }
            return .unknown
        }
    }

    private func parseDate(from dateString: String) -> Date? {
        // ESPN format: "2025-12-05T01:15Z" (no seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        // Try format without seconds first (ESPN's common format)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        // Try with seconds
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        // Try ISO8601 formatter as fallback
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }

        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso8601Formatter.date(from: dateString)
    }
}
