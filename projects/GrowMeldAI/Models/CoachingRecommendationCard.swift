// Views/CoachingRecommendationCard.swift
struct CoachingRecommendationCard: View {
    @ObservedObject var viewModel: CoachingViewModel
    let recommendation: CoachingRecommendation
    
    var body: some View {
        VStack {
            Text(recommendation.categoryName)
            Text(recommendation.prescription)
            Slider(value: Binding(...))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(recommendation.accessibilityLabel)
        .accessibilityValue(recommendation.accessibilityValue)
        .accessibilityHint(recommendation.accessibilityHint)
        .accessibilityAction(.increment) {
            viewModel.adjustConfidence(for: recommendation.id, increase: true)
        }
        .accessibilityAction(.decrement) {
            viewModel.adjustConfidence(for: recommendation.id, increase: false)
        }
        .accessibilityCustomAction(
            NSLocalizedString("action.practiceNow", comment: "VoiceOver custom action"),
            handler: {
                viewModel.practiceNowAction(categoryId: recommendation.categoryId)
                return true
            }
        )
    }
}