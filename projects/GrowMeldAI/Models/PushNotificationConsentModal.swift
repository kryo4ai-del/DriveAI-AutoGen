import SwiftUI

struct PushNotificationConsentModal: View {
    let trigger: PushNotificationTrigger
    let onAllow: () -> Void
    let onNotNow: () -> Void
    let onNeverAsk: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon and headline
            VStack(spacing: 12) {
                Image(systemName: trigger.systemIcon)
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .accessibilityLabel(trigger.accessibilityIconLabel)
                
                Text(trigger.headline)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(trigger.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            
            Spacer()
            
            // Buttons: Equal visual weight (WCAG 2.1 AA + App Store Guideline 5.1.1)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: onNotNow) {
                        Text("Später")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    .accessibilityHint("Diese Benachrichtigung kannst du später in den Einstellungen aktivieren")
                    
                    Button(action: onAllow) {
                        Text("Aktivieren")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    .accessibilityHint("Aktiviert Push-Benachrichtigungen für diesen Bereich")
                }
                
                Button(action: onNeverAsk) {
                    Text("Nicht mehr fragen")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .foregroundColor(.secondary)
                }
                .accessibilityHint("Du kannst deine Wahl jederzeit in den Einstellungen ändern")
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        .accessibilityElement(children: .contain)
    }
}

// Add accessibility properties to trigger
extension PushNotificationTrigger {
    var accessibilityIconLabel: String {
        switch self {
        case .examPassed:
            return "Prüfung bestanden"
        case .examFailed:
            return "Prüfung nicht bestanden"
        case .streakMilestone(let days):
            return "\(days)-Tage Streak erreicht"
        }
    }
}

#Preview {
    PushNotificationConsentModal(
        trigger: .examPassed(score: 85),
        onAllow: { print("Allowed") },
        onNotNow: { print("Not now") },
        onNeverAsk: { print("Never ask") }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}