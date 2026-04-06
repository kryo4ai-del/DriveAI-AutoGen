// Views/CoachingRecommendationCard.swift
import SwiftUI

struct CoachingRecommendationCard: View {
    @ObservedObject var viewModel: CoachingViewModel
    let recommendation: CoachingViewModel.CoachingRecommendation
    
    var body: some View {
        VStack {
            Text(recommendation.categoryName)
            Text(recommendation.prescription)
            Slider(value: Binding(
                get: { recommendation.confidence },
                set: { newValue in
                    viewModel.setConfidence(for: recommendation.id, value: newValue)
                }
            ))
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