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
                
                Text(String(localized: "streak.current", bundle: .module))
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
                
                Text(String(localized: "streak.longest", bundle: .module))
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
                    
                    Text(String(localized: "streak.active", bundle: .module))
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
        let currentLabel = String(
            format: NSLocalizedString(
                "streak.current.a11y",
                bundle: .module,
                comment: "Current streak accessibility"
            ),
            streak.currentStreak
        )
        
        let longestLabel = String(
            format: NSLocalizedString(
                "streak.longest.a11y",
                bundle: .module,
                comment: "Longest streak accessibility"
            ),
            streak.longestStreak
        )
        
        let statusLabel = streak.isActive
            ? String(localized: "streak.active.a11y", bundle: .module)
            : String(localized: "streak.inactive.a11y", bundle: .module)
        
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