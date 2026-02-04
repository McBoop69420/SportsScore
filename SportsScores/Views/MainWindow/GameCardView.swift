import SwiftUI

struct GameCardView: View {
    let game: Game

    @State private var isHovering = false
    @State private var pulseAnimation = false

    private var awayColor: Color {
        Color(hex: game.awayTeam.displayColor) ?? .blue
    }

    private var homeColor: Color {
        Color(hex: game.homeTeam.displayColor) ?? .red
    }

    private var awayIsWinner: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return away > home && game.isCompleted
    }

    private var homeIsWinner: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return home > away && game.isCompleted
    }

    var body: some View {
        VStack(spacing: 0) {
            // Status header
            statusHeader

            // Teams and score
            HStack(spacing: 12) {
                // Away team
                teamColumn(team: game.awayTeam, score: game.awayScore, isWinner: awayIsWinner, color: awayColor)

                // Score/VS divider
                scoreDivider

                // Home team
                teamColumn(team: game.homeTeam, score: game.homeScore, isWinner: homeIsWinner, color: homeColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // Footer with venue/broadcast
            if game.venue != nil || game.broadcast != nil {
                footerInfo
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            awayColor.opacity(0.3),
                            Color(nsColor: .controlBackgroundColor),
                            homeColor.opacity(0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(isHovering ? 0.15 : 0.08), radius: isHovering ? 12 : 6, x: 0, y: isHovering ? 4 : 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(game.isLive ? .red.opacity(0.3) : .clear, lineWidth: 2)
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .onAppear {
            if game.isLive {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        HStack {
            if game.isLive {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .scaleEffect(pulseAnimation ? 1.4 : 1.0)
                            .opacity(pulseAnimation ? 0.0 : 0.8)

                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }

                    Text(game.statusDetail ?? "LIVE")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.red)
            } else if game.isCompleted {
                Text("FINAL")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 4) {
                    Text(game.displayDate)
                    Text("•")
                    Text(game.displayTime)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }

            Spacer()

            // League badge
            Text(game.league.displayName)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.secondary.opacity(0.15), in: Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }

    // MARK: - Team Column

    private func teamColumn(team: Team, score: Int?, isWinner: Bool, color: Color) -> some View {
        VStack(spacing: 10) {
            // Logo with color accent and rank badge
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)

                TeamLogoView(team: team, size: 44)
            }
            .overlay {
                if isWinner {
                    Circle()
                        .strokeBorder(color, lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }
            .overlay(alignment: .topLeading) {
                if let rank = team.rank {
                    Text("#\(rank)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.9), in: Capsule())
                        .offset(x: -8, y: -4)
                }
            }

            // Team name
            Text(team.abbreviation)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            // Score
            if let score = score {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(isWinner ? .white : .primary)
                    .monospacedDigit()
                    .padding(.horizontal, isWinner ? 12 : 0)
                    .padding(.vertical, isWinner ? 4 : 0)
                    .background {
                        if isWinner {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                        }
                    }
            }

            // Record
            if let record = team.record {
                Text(record)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Score Divider

    private var scoreDivider: some View {
        VStack(spacing: 8) {
            if game.awayScore != nil && game.homeScore != nil {
                Text("-")
                    .font(.title2.weight(.light))
                    .foregroundStyle(.tertiary)
            } else {
                Text("VS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 30)
    }

    // MARK: - Footer Info

    private var footerInfo: some View {
        HStack(spacing: 12) {
            if let venue = game.venue {
                Label(venue, systemImage: "building.2")
                    .lineLimit(1)
            }

            Spacer()

            if let broadcast = game.broadcast {
                Label(broadcast, systemImage: "tv")
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }
}

#Preview {
    HStack(spacing: 16) {
        GameCardView(game: Game(
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

        GameCardView(game: Game(
            id: "2",
            league: .collegeFootball,
            homeTeam: Team(id: "3", name: "Alabama", abbreviation: "ALA", displayName: "Alabama Crimson Tide", logoURL: nil, color: "9E1B32", alternateColor: nil, record: "10-1", rank: 5),
            awayTeam: Team(id: "4", name: "Georgia", abbreviation: "UGA", displayName: "Georgia Bulldogs", logoURL: nil, color: "BA0C2F", alternateColor: nil, record: "11-0", rank: 1),
            homeScore: nil,
            awayScore: nil,
            status: .scheduled,
            startTime: Date().addingTimeInterval(3600),
            venue: "Mercedes-Benz Stadium",
            broadcast: "ESPN",
            statusDetail: nil
        ))
    }
    .frame(width: 600)
    .padding()
}
