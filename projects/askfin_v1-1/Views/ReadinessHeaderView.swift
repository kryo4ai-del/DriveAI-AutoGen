import SwiftUI
// Views/ExamReadiness/ReadinessHeaderView.swift
struct ReadinessHeaderView: View {
    let score: ReadinessScore
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score.overallScore) / 100)
                    .stroke(score.overallScore >= 70 ? Color.green : Color.red, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: score.overallScore)
                
                VStack(spacing: 4) {
                    Text("\(score.overallScore)%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7)
                    
                    Text(score.readinessLabel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Overall Readiness")
            .accessibilityValue("\(score.overallScore)% \(score.readinessLabel)")
            
            Text(score.isReadyForExam ? "You're ready for the exam!" : "Keep practicing")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Views/ExamReadiness/CategoryBreakdownView.swift
struct CategoryBreakdownView: View {
    let categories: [CategoryReadiness]
    let onSelectCategory: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            ForEach(categories) { category in
                CategoryReadinessRow(
                    category: category,
                    onTap: { onSelectCategory(category.categoryId) }
                )
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// Views/ExamReadiness/RecommendationsView.swift
struct RecommendationsView: View {
    let recommendations: [Recommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            ForEach(recommendations) { rec in
                RecommendationCard(recommendation: rec)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// Views/ExamReadiness/ExamReadinessActionButtons.swift
struct ExamReadinessActionButtons: View {
    let isReady: Bool
    let onProceedToExam: () -> Void
    let onDrillMore: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if isReady {
                Button(action: onProceedToExam) {
                    Label("Take Exam", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityHint("Take the 30-question exam simulation")
            } else {
                Button(action: onDrillMore) {
                    Label("Practice More", systemImage: "book.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityHint("Practice weak categories")
            }
        }
    }
}