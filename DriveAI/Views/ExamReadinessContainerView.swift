// ✅ RECOMMENDED: Views/ExamReadiness/ExamReadinessContainerView.swift

struct ExamReadinessContainerView: View {
    @StateObject private var reportVM = ExamReadinessReportViewModel()
    @StateObject private var recommendationVM = StudyRecommendationViewModel()
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Score card
                        ReadinessScoreCard(viewModel: reportVM)
                            .padding()
                        
                        // 2. Recommendations (collapsible on iPad)
                        if !recommendationVM.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("readiness.recommendations.title")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(recommendationVM.recommendations) { rec in
                                    FocusRecommendationRow(
                                        recommendation: rec,
                                        onDismiss: { recommendationVM.dismiss(categoryId: rec.categoryId) },
                                        onTap: { 
                                            await recommendationVM.navigateToCategory(rec.categoryId)
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // 3. Category breakdown
                        CategoryReadinessGrid(viewModel: reportVM)
                            .padding()
                    }
                }
                
                // Loading state
                if reportVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationTitle("readiness.title")
            .task {
                await reportVM.loadReport()
                await recommendationVM.loadRecommendations()
            }
            .refreshable {
                async let _ = reportVM.refreshReport()
                async let _ = recommendationVM.loadRecommendations()
            }
        }
    }
}