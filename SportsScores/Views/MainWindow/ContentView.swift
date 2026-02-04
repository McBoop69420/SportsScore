import SwiftUI

struct MainWindowView: View {
    @ObservedObject var viewModel: ScoresViewModel
    @State private var selectedFilter: SidebarFilter? = .live
    @State private var selectedGame: Game?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SportSidebarView(
                viewModel: viewModel,
                selectedFilter: $selectedFilter
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        } detail: {
            GameListView(
                viewModel: viewModel,
                selectedFilter: selectedFilter ?? .live,
                selectedGame: $selectedGame
            )
        }
        .searchable(text: $viewModel.searchText, prompt: "Search teams...")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                toolbarItems
            }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailSheet(game: game)
        }
        .task {
            // Force Live selection on startup
            try? await Task.sleep(for: .milliseconds(100))
            if selectedFilter == nil || selectedFilter == .all {
                selectedFilter = .live
            }
        }
    }

    @ViewBuilder
    private var toolbarItems: some View {
        Button {
            Task { await viewModel.refresh() }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
        .keyboardShortcut("r", modifiers: .command)

        if viewModel.isLoading {
            ProgressView()
                .scaleEffect(0.7)
        } else if let lastUpdated = viewModel.lastUpdated {
            Text("Updated: \(lastUpdated, style: .time)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct GameListView: View {
    @ObservedObject var viewModel: ScoresViewModel
    let selectedFilter: SidebarFilter
    @Binding var selectedGame: Game?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var displayedGames: [Game] {
        var games = viewModel.filteredGames

        switch selectedFilter {
        case .live:
            games = games.filter { $0.isLive }
        case .today:
            games = games.filter { Calendar.current.isDateInToday($0.startTime) }
        case .tomorrow:
            games = games.filter { Calendar.current.isDateInTomorrow($0.startTime) }
        case .all:
            break
        case .sport(let sport):
            games = games.filter { $0.league.sport == sport }
        }

        return games
    }

    private var navigationTitle: String {
        switch selectedFilter {
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

    var body: some View {
        ScrollView {
            if displayedGames.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                LazyVStack(alignment: .leading, spacing: 24, pinnedViews: .sectionHeaders) {
                    ForEach(groupedGames.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { league in
                        Section {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(groupedGames[league] ?? []) { game in
                                    GameCardView(game: game)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedGame = game
                                        }
                                }
                            }
                        } header: {
                            sectionHeader(league.displayName)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(navigationTitle)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var groupedGames: [League: [Game]] {
        Dictionary(grouping: displayedGames, by: { $0.league })
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(emptyStateTitle, systemImage: emptyStateIcon)
        } description: {
            Text(emptyStateDescription)
        }
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .live:
            return "No Live Games"
        case .today:
            return "No Games Today"
        case .tomorrow:
            return "No Games Tomorrow"
        default:
            return "No Games"
        }
    }

    private var emptyStateIcon: String {
        switch selectedFilter {
        case .live:
            return "livephoto"
        case .today:
            return "calendar"
        case .tomorrow:
            return "calendar.badge.clock"
        default:
            return "calendar.badge.exclamationmark"
        }
    }

    private var emptyStateDescription: String {
        switch selectedFilter {
        case .live:
            return "There are no games in progress right now"
        case .today:
            return "No games scheduled for today"
        case .tomorrow:
            return "No games scheduled for tomorrow"
        default:
            return "No games scheduled for the selected filters"
        }
    }
}

#Preview {
    MainWindowView(viewModel: ScoresViewModel())
}
