import SwiftUI

struct SportSidebarView: View {
    @ObservedObject var viewModel: ScoresViewModel
    @Binding var selectedFilter: SidebarFilter?

    var body: some View {
        List(selection: $selectedFilter) {
            Section("Overview") {
                Label {
                    HStack {
                        Text("Live")
                        Spacer()
                        if viewModel.liveGames.count > 0 {
                            Text("\(viewModel.liveGames.count)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red, in: Capsule())
                        }
                    }
                } icon: {
                    Image(systemName: "livephoto")
                        .foregroundStyle(.red)
                }
                .tag(SidebarFilter.live)

                Label {
                    HStack {
                        Text("Today")
                        Spacer()
                        Text("\(viewModel.todayGames.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                }
                .tag(SidebarFilter.today)

                Label {
                    HStack {
                        Text("Tomorrow")
                        Spacer()
                        Text("\(viewModel.tomorrowGames.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.orange)
                }
                .tag(SidebarFilter.tomorrow)

                Label {
                    HStack {
                        Text("All Sports")
                        Spacer()
                        Text("\(viewModel.games.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "sportscourt.fill")
                }
                .tag(SidebarFilter.all)
            }

            Section("Sports") {
                ForEach(Sport.allCases) { sport in
                    SportRow(
                        sport: sport,
                        gameCount: gameCount(for: sport),
                        liveCount: liveCount(for: sport),
                        isEnabled: viewModel.selectedSports.contains(sport),
                        onToggle: { viewModel.toggleSport(sport) }
                    )
                    .tag(SidebarFilter.sport(sport))
                }
            }

            Section("Leagues") {
                ForEach(League.allCases) { league in
                    LeagueRow(
                        league: league,
                        gameCount: gameCount(for: league),
                        isEnabled: viewModel.selectedLeagues.contains(league),
                        onToggle: { viewModel.toggleLeague(league) }
                    )
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Sports")
    }

    private func gameCount(for sport: Sport) -> Int {
        viewModel.games.filter { $0.league.sport == sport }.count
    }

    private func liveCount(for sport: Sport) -> Int {
        viewModel.games.filter { $0.league.sport == sport && $0.isLive }.count
    }

    private func gameCount(for league: League) -> Int {
        viewModel.games.filter { $0.league == league }.count
    }
}

struct SportRow: View {
    let sport: Sport
    let gameCount: Int
    let liveCount: Int
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: sport.sfSymbol)
                .frame(width: 20)
                .foregroundStyle(isEnabled ? .primary : .secondary)

            Text(sport.displayName)
                .foregroundStyle(isEnabled ? .primary : .secondary)

            Spacer()

            if liveCount > 0 {
                Text("\(liveCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red, in: Capsule())
            }

            Text("\(gameCount)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()
        }
    }
}

struct LeagueRow: View {
    let league: League
    let gameCount: Int
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: league.sport.sfSymbol)
                .frame(width: 20)
                .foregroundStyle(isEnabled ? .primary : .tertiary)
                .font(.caption)

            Text(league.displayName)
                .font(.subheadline)
                .foregroundStyle(isEnabled ? .primary : .secondary)

            Spacer()

            Text("\(gameCount)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()
        }
    }
}

#Preview {
    SportSidebarView(
        viewModel: ScoresViewModel(),
        selectedFilter: .constant(.live as SidebarFilter?)
    )
    .frame(width: 250, height: 500)
}
