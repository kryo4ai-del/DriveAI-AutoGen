struct ExamResultScreen: View {
    let examResult: ExamResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Pass/fail header (unchanged)
            PassFailHeader(passed: examResult.passed, score: examResult.score)
            
            // NEW: Category-level breakdown (diagnostic feedback)
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance by Category")
                    .font(.headline)
                
                ForEach(examResult.categoryScores, id: \.categoryId) { category in
                    CategoryPerformanceRow(
                        name: category.name,
                        score: category.score,
                        total: category.total,
                        trend: category.trend
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // NEW: Adaptive next-step recommendation
            if !examResult.passed {
                VStack(spacing: 12) {
                    Text("Recommended Practice")
                        .font(.headline)
                    
                    // Spaced repetition logic:
                    // - Weakest categories: 1-day interval
                    // - Middle categories: 3-day interval
                    // - Strong categories: skip for now (interleaving happens naturally)
                    
                    ForEach(examResult.practiceRecommendations) { rec in
                        RecommendationCard(
                            categoryName: rec.categoryName,
                            questionCount: rec.suggestedQuestions,
                            interval: rec.rescheduleInterval,
                            reason: rec.rationale
                        )
                    }
                }
            } else {
                // For passed exams: celebrate + suggest maintenance
                VStack(spacing: 12) {
                    Text("You're Exam-Ready! 🎉")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("To maintain readiness, do a 15-minute review every 2 days before your official test.")
                        .font(.body)
                    
                    Button(action: { scheduleMaintenanceReview() }) {
                        Label("Schedule Refresher", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear {
            // Track not just pass/fail, but diagnostic data
            Task {
                await analyticsService.track(
                    .examCompleted(
                        score: examResult.score,
                        passed: examResult.passed,
                        durationSeconds: Int(examResult.duration),
                        weakestCategory: examResult.categoryScores.min(by: { $0.score < $1.score })?.categoryId
                    )
                )
            }
        }
    }
    
    private func scheduleMaintenanceReview() {
        // Link to calendar or reminder system
    }
}

// Supporting models

struct CategoryScore {
    let categoryId: String
    let name: String
    let score: Int  // questions correct out of category total
    let total: Int
    let trend: PerformanceTrend
    
    enum PerformanceTrend {
        case improving, stable, declining
    }
}

struct PracticeRecommendation {
    let categoryName: String
    let suggestedQuestions: Int
    let rescheduleInterval: TimeInterval
    let rationale: String
    
    enum TimeInterval {
        case oneDay, threeDays, sevenDays
    }
}