// Models/ReadinessScore.swift
struct ReadinessScore {
    let overall: Int  // 0-100
    let trendDirection: TrendDirection  // improving, stable, declining
    let weakAreas: [String]  // categories needing focus
    let estimatedPassProbability: Double  // Bayesian: P(pass | current performance)
    
    enum TrendDirection {
        case improving, stable, declining
    }
}

// Services/ReadinessCalculator.swift
class ReadinessCalculator {
    func calculateReadiness(from analytics: AnalyticsSnapshot) -> ReadinessScore {
        // 1. Baseline: 70% = 21/30 needed to pass (German driving exam standard)
        let passThreshold = 0.70
        
        // 2. Current accuracy across all categories
        let currentAccuracy = analytics.correctAnswers / analytics.totalAnswered
        
        // 3. Trend: compare last 7 days vs. previous 7 days (Ebbinghaus forgetting curve checkpoint)
        let last7DaysAccuracy = analytics.accuracyLast7Days
        let prev7DaysAccuracy = analytics.accuracyPrev7Days
        let trendDelta = last7DaysAccuracy - prev7DaysAccuracy
        
        let trend: ReadinessScore.TrendDirection = 
            trendDelta > 0.05 ? .improving :
            trendDelta < -0.05 ? .declining : .stable
        
        // 4. Weak areas: categories < 70%
        let weakAreas = analytics.categoryAccuracies
            .filter { $0.value < passThreshold }
            .map { $0.key }
        
        // 5. Bayesian estimate: P(pass exam | current performance)
        // Simplified: assume binomial distribution (30 questions, p = currentAccuracy)
        let passProb = binomialCDF(n: 30, k: 21, p: currentAccuracy)
        
        // 6. Readiness score: scale 0-100
        // 0-40: not ready (< 50% accuracy)
        // 40-70: developing (50-75% accuracy)
        // 70-100: ready (> 75%, improving trend)
        let baseScore = Int(currentAccuracy * 100)
        let scoreAdjustment = trend == .improving ? 5 : (trend == .declining ? -5 : 0)
        let readinessScore = max(0, min(100, baseScore + scoreAdjustment))
        
        return ReadinessScore(
            overall: readinessScore,
            trendDirection: trend,
            weakAreas: weakAreas,
            estimatedPassProbability: passProb
        )
    }
}

// In ProfileView
struct ReadinessWidget: View {
    let readiness: ReadinessScore
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Exam Readiness")
                    .font(.headline)
                Spacer()
                Text("\(readiness.overall)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(readinessColor)
            }
            
            // Visual gauge
            ProgressView(value: Double(readiness.overall) / 100)
                .tint(readinessColor)
            
            // Narrative feedback (CRITICAL for anxiety reduction)
            VStack(alignment: .leading, spacing: 4) {
                Text(readinessNarrative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !readiness.weakAreas.isEmpty {
                    Text("Focus: \(readiness.weakAreas.prefix(2).joined(separator: ", "))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var readinessNarrative: String {
        let trend = readiness.trendDirection == .improving 
            ? "improving steadily" 
            : readiness.trendDirection == .declining
                ? "slipping—increase practice"
                : "stable—maintain pace"
        
        let passLikelihood = readiness.estimatedPassProbability
        let passText: String
        if passLikelihood > 0.85 {
            passText = "You're likely ready to pass."
        } else if passLikelihood > 0.65 {
            passText = "You're on track. Keep practicing weak areas."
        } else if passLikelihood > 0.40 {
            passText = "More practice needed before your exam date."
        } else {
            passText = "Start with the basics—focus on foundational concepts."
        }
        
        return "\(trend). \(passText)"
    }
    
    private var readinessColor: Color {
        readiness.overall >= 70 ? .green :
        readiness.overall >= 50 ? .yellow :
        .red
    }
}