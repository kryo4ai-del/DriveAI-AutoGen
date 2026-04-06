// Views/Streak/StreakCardView.swift
struct StreakCardView: View {
    let streak: UserStreak
    
    var body: some View {
        VStack(spacing: 20) {
            // Streak Count (Hero Section)
            VStack(alignment: .center, spacing: 8) {
                Text("🔥")
                    .font(.system(size: 60))
                    .accessibilityHidden(true)
                
                Text("\(streak.currentCount)")
                    .font(.system(size: 80, weight: .bold))
                    .lineLimit(1)
                    .accessibilityLabel("Aktuelle Strähne")
                    .accessibilityValue("\(streak.currentCount) Tage")
                    .accessibilityHint("Sie üben \(streak.currentCount) Tage in Folge. Behalten Sie es bei!")
                
                Text("Tage in Folge")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            
            // Best Streak
            HStack(spacing: 12) {
                Label(
                    "Persönlicher Rekord",
                    systemImage: "medal.fill"
                )
                .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(streak.longestCount)")
                    .font(.headline)
                    .accessibilityLabel("Bester Rekord: \(streak.longestCount) Tage")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            
            // Status Message
            if streak.isActive {
                Label(
                    "Strähne läuft! Üben Sie heute, um sie zu bewahren.",
                    systemImage: "checkmark.circle.fill"
                )
                .foregroundColor(.green)
                .font(.caption)
                .accessibilityLabel("Strähne aktiv: Üben Sie heute, um sie zu bewahren")
            } else {
                Label(
                    "Strähne unterbrochen. Starten Sie eine neue Strähne!",
                    systemImage: "xmark.circle.fill"
                )
                .foregroundColor(.red)
                .font(.caption)
                .accessibilityLabel("Strähne unterbrochen. Starten Sie eine neue")
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}