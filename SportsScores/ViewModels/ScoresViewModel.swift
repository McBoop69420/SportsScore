import Foundation
import SwiftUI
import Combine

@MainActor
class ScoresViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUpdated: Date?

    @Published var selectedSports: Set<Sport> = Set(Sport.allCases)
    @Published var selectedLeagues: Set<League> = Set(League.allCases)
    @Published var showLiveOnly = false
    @Published var searchText = ""

    @AppStorage("refreshInterval") var refreshInterval: Double = 30
    @AppStorage("enabledLeagues") private var enabledLeaguesData: Data = Data()

    private var refreshTask: Task<Void, Never>?
    private let service = SportsDataService.shared

    var filteredGames: [Game] {
        var filtered = games

        if !selectedLeagues.isEmpty {
            filtered = filtered.filter { selectedLeagues.contains($0.league) }
        }

        if showLiveOnly {
            filtered = filtered.filter { $0.isLive }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter { game in
                game.homeTeam.displayName.localizedCaseInsensitiveContains(searchText) ||
                game.awayTeam.displayName.localizedCaseInsensitiveContains(searchText) ||
                game.homeTeam.abbreviation.localizedCaseInsensitiveContains(searchText) ||
                game.awayTeam.abbreviation.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }

    var liveGames: [Game] {
        games.filter { $0.isLive }
    }

    var todayGames: [Game] {
        games.filter { Calendar.current.isDateInToday($0.startTime) }
    }

    var tomorrowGames: [Game] {
        games.filter { Calendar.current.isDateInTomorrow($0.startTime) }
    }

    var upcomingGames: [Game] {
        games.filter { $0.isUpcoming }
    }

    var completedGames: [Game] {
        games.filter { $0.isCompleted }
    }

    var gamesByLeague: [League: [Game]] {
        Dictionary(grouping: filteredGames, by: { $0.league })
    }

    var gamesBySport: [Sport: [Game]] {
        var result: [Sport: [Game]] = [:]
        for game in filteredGames {
            let sport = game.league.sport
            result[sport, default: []].append(game)
        }
        return result
    }

    init() {
        loadEnabledLeagues()
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(refreshInterval))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refresh() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let activeLeagues = Array(selectedLeagues)
            let fetchedGames = try await service.fetchScores(for: activeLeagues)
            games = fetchedGames
            lastUpdated = Date()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func toggleSport(_ sport: Sport) {
        if selectedSports.contains(sport) {
            selectedSports.remove(sport)
            for league in sport.leagues {
                selectedLeagues.remove(league)
            }
        } else {
            selectedSports.insert(sport)
            for league in sport.leagues {
                selectedLeagues.insert(league)
            }
        }
        saveEnabledLeagues()
    }

    func toggleLeague(_ league: League) {
        if selectedLeagues.contains(league) {
            selectedLeagues.remove(league)
        } else {
            selectedLeagues.insert(league)
        }
        updateSportSelection()
        saveEnabledLeagues()
    }

    private func updateSportSelection() {
        for sport in Sport.allCases {
            let sportLeagues = Set(sport.leagues)
            if sportLeagues.isSubset(of: selectedLeagues) {
                selectedSports.insert(sport)
            } else if sportLeagues.isDisjoint(with: selectedLeagues) {
                selectedSports.remove(sport)
            }
        }
    }

    private func saveEnabledLeagues() {
        let leagueStrings = selectedLeagues.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(leagueStrings) {
            enabledLeaguesData = data
        }
    }

    private func loadEnabledLeagues() {
        guard !enabledLeaguesData.isEmpty else { return }
        if let leagueStrings = try? JSONDecoder().decode([String].self, from: enabledLeaguesData) {
            selectedLeagues = Set(leagueStrings.compactMap { League(rawValue: $0) })
            updateSportSelection()
        }
    }
}
