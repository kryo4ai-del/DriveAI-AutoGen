// Presentation/Views/Coaching/CoachingRecommendationListView.swift

struct CoachingRecommendationListView: View {
    @StateObject private var viewModel: CoachingRecommendationViewModel
    
    init(user: User) {
        _viewModel = StateObject(
            wrappedValue: CoachingRecommendationViewModel(user: user)
        )
    }
    
    var body: some View {
        Group {
            if viewModel.recommendations.isEmpty {
                emptyState
            } else {
                recommendationsList
            }
        }
        .task {
            await viewModel.loadRecommendations(for: viewModel.user)
        }
    }
    
    @ViewBuilder
    private var recommendationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recommendations) { rec in
                    RecommendationCardView(
                        recommendation: rec,
                        onDismiss: {
                            Task {
                                await viewModel.dismissRecommendation(rec.id)
                            }
                        },
                        onActionTap: {
                            handleAction(for: rec)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Hervorragende Vorbereitung!")
                .font(.headline)
            
            Text("Du bist gut vorbereitet. Weiter so!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func handleAction(for recommendation: CoachingRecommendation) {
        // Navigate to target screen based on recommendation.actionUrl
    }
}