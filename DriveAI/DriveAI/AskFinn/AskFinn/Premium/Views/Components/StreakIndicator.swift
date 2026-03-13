import SwiftUI

struct StreakIndicator: View {
    let streak: StreakData

    var body: some View {
        HStack(spacing: 16) {
            // Current streak
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title2)

                    Text("\(streak.currentStreak)")
                        .font(.headline)
                }

                Text("Aktueller Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            Divider()
                .frame(height: 50)

            // Longest streak
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)

                    Text("\(streak.longestStreak)")
                        .font(.headline)
                }

                Text("Bester Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Status indicator
            if streak.isActive {
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)

                    Text("Aktiv")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(streakAccessibilityLabel)
        )
    }

    private var streakAccessibilityLabel: String {
        let currentLabel = "\(streak.currentStreak) Tage aktueller Streak"
        let longestLabel = "\(streak.longestStreak) Tage bester Streak"
        let statusLabel = streak.isActive ? "Streak ist aktiv" : "Streak ist inaktiv"
        return "\(currentLabel), \(longestLabel), \(statusLabel)"
    }
}

#Preview {
    StreakIndicator(
        streak: StreakData(
            currentStreak: 7,
            longestStreak: 14,
            lastActivityDate: Date()
        )
    )
    .padding()
}
