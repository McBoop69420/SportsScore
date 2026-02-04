import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: ScoresViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            scrollableContent
            Divider()
            footerView
        }
        .frame(width: 320)
    }

    private var headerView: some View {
        HStack {
            Text("Sports Scores")
                .font(.headline)

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            } else if let lastUpdated = viewModel.lastUpdated {
                Text(lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !viewModel.liveGames.isEmpty {
                    sectionHeader("Live")
                    ForEach(viewModel.liveGames) { game in
                        ScoreRowView(game: game)
                    }
                }

                if !viewModel.upcomingGames.isEmpty {
                    sectionHeader("Upcoming")
                    ForEach(viewModel.upcomingGames.prefix(10)) { game in
                        ScoreRowView(game: game)
                    }
                }

                if !viewModel.completedGames.isEmpty {
                    sectionHeader("Final")
                    ForEach(viewModel.completedGames.prefix(5)) { game in
                        ScoreRowView(game: game)
                    }
                }

                if viewModel.games.isEmpty && !viewModel.isLoading {
                    emptyStateView
                }
            }
        }
        .frame(maxHeight: 400)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sportscourt")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No games scheduled")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var footerView: some View {
        HStack {
            Button {
                openWindow(id: "main")
            } label: {
                Label("Open Window", systemImage: "macwindow")
            }
            .buttonStyle(.borderless)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
