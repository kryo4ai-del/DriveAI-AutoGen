// Views/StreakWidget.swift (hypothetical)
struct StreakWidget: View {
    let streak: UserStreak
    
    var body: some View {
        VStack(spacing: 8) {
            Label {
                VStack(alignment: .leading) {
                    Text("Aktuelle Strähne")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(streak.currentStreak))
                        .font(.system(.title, design: .default))
                        .accessibilityLabel("Aktuelle Strähne: \(streak.currentStreak) Tage")
                }
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)  // Decorative
            }
            
            Label {
                VStack(alignment: .leading) {
                    Text("Längste Strähne")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(streak.longestStreak))
                        .font(.system(.body, design: .default))
                        .accessibilityLabel("Längste Strähne: \(streak.longestStreak) Tage")
                }
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}