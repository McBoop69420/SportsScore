import SwiftUI

struct ScoreRowView: View {
    let game: Game

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                leagueTag
                Spacer()
                statusBadge
            }

            HStack(spacing: 8) {
                teamRow(team: game.awayTeam, score: game.awayScore, isWinning: awayIsWinning)
            }

            HStack(spacing: 8) {
                teamRow(team: game.homeTeam, score: game.homeScore, isWinning: homeIsWinning)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .contentShape(Rectangle())
    }

    private var homeIsWinning: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return home > away
    }

    private var awayIsWinning: Bool {
        guard let home = game.homeScore, let away = game.awayScore else { return false }
        return away > home
    }

    private var leagueTag: some View {
        Text(game.league.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
    }

    private var statusBadge: some View {
        Group {
            if game.isLive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 6, height: 6)
                    Text(game.statusDetail ?? "LIVE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.red)
            } else if game.isUpcoming {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(game.displayDate)
                        .font(.caption2)
                    Text(game.displayTime)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
            } else {
                Text(game.displayTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func teamRow(team: Team, score: Int?, isWinning: Bool) -> some View {
        HStack(spacing: 8) {
            TeamLogoView(team: team, size: 20)

            Text(team.abbreviation)
                .font(.system(.subheadline, design: .rounded, weight: isWinning ? .bold : .regular))
                .frame(width: 40, alignment: .leading)

            if let record = team.record {
                Text("(\(record))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let score = score {
                Text("\(score)")
                    .font(.system(.subheadline, design: .rounded, weight: isWinning ? .bold : .regular))
                    .monospacedDigit()
            }
        }
    }
}
