import Foundation

actor SportsDataService {
    static let shared = SportsDataService()

    private let baseURL = "https://site.api.espn.com/apis/site/v2/sports"
    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
    }

    func fetchScores(for league: League) async throws -> [Game] {
        let urlString = "\(baseURL)/\(league.espnSport)/\(league.espnLeague)/scoreboard"

        guard let url = URL(string: urlString) else {
            throw SportsDataError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SportsDataError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw SportsDataError.httpError(httpResponse.statusCode)
        }

        let espnResponse = try decoder.decode(ESPNScoreboardResponse.self, from: data)
        return espnResponse.toGames(league: league)
    }

    func fetchScores(for leagues: [League]) async throws -> [Game] {
        try await withThrowingTaskGroup(of: [Game].self) { group in
            for league in leagues {
                group.addTask {
                    do {
                        return try await self.fetchScores(for: league)
                    } catch {
                        print("Error fetching \(league.displayName): \(error)")
                        return []
                    }
                }
            }

            var allGames: [Game] = []
            for try await games in group {
                allGames.append(contentsOf: games)
            }

            return allGames.sorted { game1, game2 in
                if game1.isLive && !game2.isLive { return true }
                if !game1.isLive && game2.isLive { return false }
                return game1.startTime < game2.startTime
            }
        }
    }

    func fetchAllScores() async throws -> [Game] {
        try await fetchScores(for: League.allCases)
    }
}

enum SportsDataError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
