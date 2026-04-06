struct ProfileScreenView: View {
    @EnvironmentObject var viewModel: PerformanceTrackerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Readiness gauge only (visual, not numeric)
            PerformanceGaugeView(
                accuracy: viewModel.examReadiness.overallScore,
                readinessLevel: viewModel.examReadiness.readinessLevel
            )
            
            // Single actionable recommendation (not a list)
            if let topAction = viewModel.singleTopRecommendation {
                RecommendationCard(recommendation: topAction)
                    .padding()
            }
            
            // Optional: Exam countdown (temporal pressure, motivating)
            ExamCountdownCard(daysUntilExam: viewModel.daysUntilExam)
                .padding()
        }
    }
}

// Top recommendation = highest leverage (weakest category + most improvement potential)
var singleTopRecommendation: LearningRecommendation? {
    recommendations
        .sorted { $0.priority > $1.priority }  // Critical first
        .first
}