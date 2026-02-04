import SwiftUI

struct TeamLogoView: View {
    let team: Team
    var size: CGFloat = 32

    var body: some View {
        Group {
            if let logoURL = team.logoURL {
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
    }

    private var placeholder: some View {
        ZStack {
            Circle()
                .fill(Color(hex: team.primaryColor) ?? .gray)
            Text(team.abbreviation.prefix(1))
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

struct ScoreBadgeView: View {
    let homeScore: Int?
    let awayScore: Int?
    let isLive: Bool

    var body: some View {
        HStack(spacing: 4) {
            if let away = awayScore, let home = homeScore {
                Text("\(away)")
                    .fontWeight(away > home ? .bold : .regular)
                Text("-")
                    .foregroundStyle(.secondary)
                Text("\(home)")
                    .fontWeight(home > away ? .bold : .regular)
            } else {
                Text("vs")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.system(.title3, design: .rounded))
        .monospacedDigit()
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(isLive ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1))
        }
    }
}
