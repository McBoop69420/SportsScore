import SwiftUI

struct GameDetailView: View {
    let game: Game

    @State private var pulseAnimation = false

    private var awayColor: Color {
        Color(hex: game.awayTeam.primaryColor) ?? .blue
    }

    private var homeColor: Color {
        Color(hex: game.homeTeam.primaryColor) ?? .red
    }

    private var awayIsWinner: Bool {
        guard let away = game.awayScore, let home = game.homeScore, game.isCompleted else { return false }
        return away > home
    }

    private var homeIsWinner: Bool {
        guard let away = game.awayScore, let home = game.homeScore, game.isCompleted else { return false }
        return home > away
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerGradient

                VStack(spacing: 24) {
                    statusBadge
                        .padding(.top, -30)

                    scoreSection

                    detailsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(game.league.displayName)
        .onAppear {
            if game.isLive {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
    }

    // MARK: - Header Gradient

    private var headerGradient: some View {
        ZStack {
            // Team color gradient background
            LinearGradient(
                colors: [
                    awayColor.opacity(0.8),
                    awayColor.opacity(0.4),
                    homeColor.opacity(0.4),
                    homeColor.opacity(0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            // Overlay for depth
            LinearGradient(
                colors: [
                    .black.opacity(0.3),
                    .clear,
                    .black.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // League info
            VStack(spacing: 8) {
                Image(systemName: game.league.sport.sfSymbol)
                    .font(.system(size: 28))
                Text(game.league.displayName)
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .frame(height: 120)
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        Group {
            if game.isLive {
                liveStatusBadge
            } else if game.isCompleted {
                finalStatusBadge
            } else {
                scheduledStatusBadge
            }
        }
    }

    private var liveStatusBadge: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.red.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0.0 : 0.8)

                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
            }

            Text(game.statusDetail ?? "LIVE")
                .font(.headline.weight(.bold))
        }
        .foregroundStyle(.red)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 2)
        }
        .overlay {
            Capsule()
                .strokeBorder(.red.opacity(0.5), lineWidth: 2)
        }
    }

    private var finalStatusBadge: some View {
        Text("FINAL")
            .font(.headline.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
    }

    private var scheduledStatusBadge: some View {
        VStack(spacing: 2) {
            Text(game.displayDate)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(game.displayTime)
                .font(.title3.weight(.bold))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Score Section

    private var scoreSection: some View {
        HStack(spacing: 0) {
            // Away team
            teamPanel(
                team: game.awayTeam,
                score: game.awayScore,
                isHome: false,
                isWinner: awayIsWinner,
                teamColor: awayColor
            )

            // VS / Score divider
            scoreDivider

            // Home team
            teamPanel(
                team: game.homeTeam,
                score: game.homeScore,
                isHome: true,
                isWinner: homeIsWinner,
                teamColor: homeColor
            )
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    private func teamPanel(team: Team, score: Int?, isHome: Bool, isWinner: Bool, teamColor: Color) -> some View {
        VStack(spacing: 16) {
            // Team logo with color ring and rank badge
            ZStack {
                Circle()
                    .fill(teamColor.opacity(0.15))
                    .frame(width: 110, height: 110)

                Circle()
                    .strokeBorder(
                        teamColor.opacity(isWinner ? 1.0 : 0.3),
                        lineWidth: isWinner ? 4 : 2
                    )
                    .frame(width: 100, height: 100)

                TeamLogoView(team: team, size: 80)
            }
            .overlay(alignment: .topTrailing) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .offset(x: 8, y: -4)
                }
            }
            .overlay(alignment: .topLeading) {
                if let rank = team.rank {
                    Text("#\(rank)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(teamColor, in: Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .offset(x: -12, y: -4)
                }
            }

            // Score
            if let score = score {
                Text("\(score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(isWinner ? teamColor : .primary)
                    .shadow(color: isWinner ? teamColor.opacity(0.3) : .clear, radius: 8, x: 0, y: 0)
            }

            // Team info
            VStack(spacing: 6) {
                Text(team.displayName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let record = team.record {
                    Text(record)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if isHome {
                    Text("HOME")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(teamColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(teamColor.opacity(0.15), in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }

    private var scoreDivider: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(width: 1, height: 40)

            if game.awayScore != nil && game.homeScore != nil {
                Text("-")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                Text("VS")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(width: 1, height: 40)
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Info")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 14) {
                if let venue = game.venue {
                    GridRow {
                        Label("Venue", systemImage: "building.2")
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(venue)
                            .fontWeight(.medium)
                    }
                }

                if let broadcast = game.broadcast {
                    GridRow {
                        Label("Broadcast", systemImage: "tv")
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)
                        Text(broadcast)
                            .fontWeight(.medium)
                    }
                }

                GridRow {
                    Label("League", systemImage: "trophy")
                        .foregroundStyle(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(game.league.displayName)
                        .fontWeight(.medium)
                }

                GridRow {
                    Label("Start Time", systemImage: "clock")
                        .foregroundStyle(.secondary)
                        .frame(width: 120, alignment: .leading)
                    Text(game.startTime, style: .date) + Text(" at ") + Text(game.startTime, style: .time)
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Sheet Wrapper

struct GameDetailSheet: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Sheet header with close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            GameDetailView(game: game)
        }
        .frame(minWidth: 550, idealWidth: 600, maxWidth: 700,
               minHeight: 500, idealHeight: 600, maxHeight: 800)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview("Sheet") {
    GameDetailSheet(game: Game(
        id: "1",
        league: .collegeFootball,
        homeTeam: Team(id: "1", name: "Alabama", abbreviation: "ALA", displayName: "Alabama Crimson Tide", logoURL: nil, color: "9E1B32", alternateColor: nil, record: "10-1", rank: 5),
        awayTeam: Team(id: "2", name: "Georgia", abbreviation: "UGA", displayName: "Georgia Bulldogs", logoURL: nil, color: "BA0C2F", alternateColor: nil, record: "11-0", rank: 1),
        homeScore: 24,
        awayScore: 27,
        status: .final,
        startTime: Date(),
        venue: "Mercedes-Benz Stadium",
        broadcast: "CBS",
        statusDetail: nil
    ))
}

#Preview("Detail") {
    GameDetailView(game: Game(
        id: "1",
        league: .nfl,
        homeTeam: Team(id: "1", name: "Chiefs", abbreviation: "KC", displayName: "Kansas City Chiefs", logoURL: nil, color: "E31837", alternateColor: nil, record: "10-2", rank: nil),
        awayTeam: Team(id: "2", name: "Bills", abbreviation: "BUF", displayName: "Buffalo Bills", logoURL: nil, color: "00338D", alternateColor: nil, record: "9-3", rank: nil),
        homeScore: 24,
        awayScore: 17,
        status: .inProgress,
        startTime: Date(),
        venue: "Arrowhead Stadium",
        broadcast: "CBS",
        statusDetail: "Q4 2:35"
    ))
    .frame(width: 600, height: 600)
}
