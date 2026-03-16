import SwiftUI
struct FocusRecommendationRow: View {
    let recommendation: FocusRecommendation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(recommendation.categoryName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Badge(urgency: recommendation.urgency)
                    }
                    
                    Text(recommendation.actionMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(recommendation.estimatedMinutesPerDay)m")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("pro Tag")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            // ✅ CRITICAL: Enforce 44pt minimum height
            .frame(minHeight: 44)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        // ✅ Add accessibility for button
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Empfohlene Kategorie: \(recommendation.categoryName)")
        .accessibilityValue("Priorität \(recommendation.priority), \(recommendation.estimatedMinutesPerDay) Minuten täglich")
        .accessibilityHint("Tippen zum Starten des Trainings")
        .accessibilityAddTraits(.isButton)
    }
}