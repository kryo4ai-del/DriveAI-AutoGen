import SwiftUI

struct SimulationResultScreen: View {
    let result: SimulationResult
    
    @StateObject private var viewModel: SimulationResultViewModel
    @Environment(\.dismiss) var dismiss
    
    init(result: SimulationResult) {
        self.result = result
        _viewModel = StateObject(wrappedValue: SimulationResultViewModel(result: result))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ResultHeader(result: result)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Performance by Category")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 8) {
                            ForEach(viewModel.categorysSortedByWeakness(), id: \.category.id) { score in
                                CategoryPerformanceRow(
                                    score: score,
                                    backgroundColor: Color(.systemGray6)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exam Readiness")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        ReadinessGaugeView(readiness: viewModel.readiness)
                            .padding(.horizontal, 16)
                    }
                    
                    ActionButtonGroup(
                        result: result,
                        onRetry: { dismiss() },
                        onDrillWeaknesses: {
                            if let weakest = viewModel.weakestCategory() {
                                print("Drill: \(weakest.category.name)")
                            }
                        },
                        onReviewTopics: { print("Review topics") },
                        onContinue: { dismiss() }
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Test Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}