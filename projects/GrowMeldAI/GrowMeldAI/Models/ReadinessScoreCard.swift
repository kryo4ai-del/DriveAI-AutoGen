// Views/Home/ReadinessScoreCard.swift
struct ReadinessScoreCard: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heutige Bereitschaft")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            HStack(alignment: .center, spacing: 16) {
                // Large score display
                VStack(alignment: .center) {
                    Text("\(viewModel.dailyReadinessScore)")
                        .font(.system(.largeTitle, design: .default))
                        .fontWeight(.bold)
                        .accessibility(hidden: true)  // Redundant with label
                    
                    Text("/\(viewModel.totalCategories)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .accessibility(hidden: true)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.readinessLabel)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("Kategorien bereit zur Wiederholung")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(viewModel.dailyReadinessScore) von \(viewModel.totalCategories) Kategorien sind heute bereit zur Wiederholung"
            )
            .accessibilityHint("Tippe zum Anzeigen der fälligen Themen")
            
            // Expandable list of ready topics
            if !viewModel.upcomingReviewTopics.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fällige Kategorien:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    ForEach(viewModel.upcomingReviewTopics, id: \.self) { topic in
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                                .accessibilityHidden(true)
                            
                            Text(topic)
                                .font(.caption)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Kategorie: \(topic)")
                    }
                }
                .padding(8)
                .background(Color.green.opacity(0.05))
                .cornerRadius(6)
                .accessibilityElement(children: .contain)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}