// Presentation/Views/Coaching/RecommendationCardView.swift

struct RecommendationCardView: View {
    let recommendation: CoachingRecommendation
    let onDismiss: () -> Void
    let onActionTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RecommendationTypeIndicator(type: recommendation.type)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Empfehlung verwerfen")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                
                Text(recommendation.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Button(action: onActionTap) {
                HStack {
                    Text(actionButtonLabel)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var actionButtonLabel: String {
        switch recommendation.type {
        case .weak_category: return "Kategorie üben"
        case .due_for_review: return "Wiederholen"
        case .confidence_gap: return "Trainieren"
        case .exam_readiness: return "Prüfungssimulation"
        }
    }
}

#Preview {
    RecommendationCardView(
        recommendation: .mock(),
        onDismiss: {},
        onActionTap: {}
    )
}