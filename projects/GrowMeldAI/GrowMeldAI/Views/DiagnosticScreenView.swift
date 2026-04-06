import SwiftUI

struct DiagnosticScreenView: View {
    @StateObject var viewModel: DiagnosticScreenViewModel
    let examResult: ExamResult
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.recommendations.isEmpty {
                    emptyView
                } else {
                    recommendationsList
                }
            }
        }
        .navigationTitle(NSLocalizedString("diagnostic_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.diagnose(examResult: examResult)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("diagnostic_intro", comment: ""))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                Text(NSLocalizedString("diagnostic_hint", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(NSLocalizedString("diagnostic_analyzing", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
        .accessibilityLabel("Analysiere deine Ergebnisse")
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                .accessibilityHidden(true)
            
            Text(NSLocalizedString("diagnostic_no_gaps", comment: ""))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(NSLocalizedString("diagnostic_perfect_score", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Keine Lernlücken gefunden")
    }
    
    private var recommendationsList: some View {
        List(viewModel.recommendations, id: \.id) { rec in
            LearningGapCardView(
                recommendation: rec,
                isExpanded: viewModel.expandedGapID == rec.gap.id,
                onToggleExpansion: {
                    viewModel.toggleGapExpansion(gapID: rec.gap.id)
                },
                onAction: { action in
                    viewModel.performAction(action, for: rec)
                }
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            
            Text(NSLocalizedString("diagnostic_error", comment: ""))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.diagnose(examResult: examResult)
                }
            }) {
                Text(NSLocalizedString("retry", comment: ""))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        DiagnosticScreenView(
            viewModel: DiagnosticScreenViewModel(
                diagnosisUseCase: MockDiagnosisUseCase(),
                recommendationUseCase: MockRecommendationUseCase(),
                analyticsService: MockAnalyticsService()
            ),
            examResult: ExamResult(
                id: UUID(),
                incorrectAnswers: [],
                score: 28,
                totalQuestions: 30,
                completedAt: .now
            )
        )
    }
}