// ViewModels/ExamReadinessViewModel.swift
import Foundation

@MainActor
final class ExamReadinessViewModel: ObservableObject {
    @Published var readiness: ExamReadiness?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userProgressService: UserProgressService
    private let localDataService: LocalDataService
    
    init(
        userProgressService: UserProgressService,
        localDataService: LocalDataService
    ) {
        self.userProgressService = userProgressService
        self.localDataService = localDataService
    }
    
    func calculateReadiness() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Background computation
                let allCategories = try await localDataService.fetchAllCategories()
                var categoryScores: [String: CategoryReadiness] = [:]
                var totalCorrect = 0
                var totalAnswered = 0
                
                for category in allCategories {
                    let progress = try await userProgressService.fetchProgressForCategory(category.id)
                    
                    let correct = progress.correctAnswers
                    let answered = progress.totalAnswersAttempted
                    let percentage = answered > 0 ? Double(correct) / Double(answered) : 0.0
                    
                    let readinessLevel = calculateReadinessLevel(percentage)
                    
                    categoryScores[category.id] = CategoryReadiness(
                        categoryID: category.id,
                        categoryName: category.name,
                        correctAnswerPercentage: percentage,
                        questionsAnswered: answered,
                        questionsCorrect: correct,
                        readinessLevel: readinessLevel
                    )
                    
                    totalCorrect += correct
                    totalAnswered += answered
                }
                
                let overallScore = totalAnswered > 0 ? Double(totalCorrect) / Double(totalAnswered) : 0.0
                
                let weakCategories = categoryScores
                    .values
                    .filter { !$0.isReadyForExam }
                    .sorted { $0.correctAnswerPercentage < $1.correctAnswerPercentage }
                    .map { $0.categoryID }
                
                let predictedPass = predictPassProbability(
                    overallScore: overallScore,
                    totalAttempts: totalAnswered,
                    categoryScores: categoryScores
                )
                
                let estimatedHours = estimateRemainingStudyHours(
                    weakCategories: weakCategories,
                    categoryScores: categoryScores
                )
                
                let result = ExamReadiness(
                    categoryScores: categoryScores,
                    overallReadinessScore: overallScore,
                    recommendedFocusCategories: weakCategories,
                    predictedPassProbability: predictedPass,
                    minimumStudyHoursRemaining: estimatedHours
                )
                
                // Explicit main thread update
                await MainActor.run {
                    self.readiness = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Readiness assessment failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func calculateReadinessLevel(_ percentage: Double) -> CategoryReadiness.ReadinessLevel {
        switch percentage {
        case 0..<0.40: return .beginner
        case 0.40..<0.70: return .intermediate
        case 0.70..<0.90: return .advanced
        case 0.90...: return .mastered
        default: return .notStarted
        }
    }
    
    /// Predict exam pass probability considering overall score, attempt count, and category distribution
    private func predictPassProbability(
        overallScore: Double,
        totalAttempts: Int,
        categoryScores: [String: CategoryReadiness]
    ) -> Double {
        guard !categoryScores.isEmpty else { return 0.0 }
        
        // Exam requires 75% to pass (22.5/30 questions)
        
        // 1. Find weakest category (weakest link matters on exam)
        let weakestScore = categoryScores.values
            .map { $0.correctAnswerPercentage }
            .min() ?? 0.0
        
        // 2. Calculate average across categories
        let categoryAverage = categoryScores.values
            .map { $0.correctAnswerPercentage }
            .reduce(0, +) / Double(categoryScores.count)
        
        // 3. Apply weakness penalty (if weakest < 60%, you'll likely fail)
        let weaknessPenalty = weakestScore < 0.60 ? 0.15 : 0.0
        
        // 4. Confidence increases with sample size (but with diminishing returns)
        let confidenceBoost = min(Double(totalAttempts) / 200.0, 0.10)
        
        // 5. Combine factors
        let probability = max(categoryAverage - weaknessPenalty + confidenceBoost, 0.0)
        
        // 6. Realistic ceiling (92% max, not 99%)
        return min(probability, 0.92)
    }
    
    /// Estimate study hours needed to reach 75% mastery in weak categories
    private func estimateRemainingStudyHours(
        weakCategories: [String],
        categoryScores: [String: CategoryReadiness]
    ) -> Int {
        var totalHours = 0
        
        for categoryID in weakCategories {
            guard let category = categoryScores[categoryID] else { continue }
            
            // Gap to 75% mastery
            let gapToMastery = max(0.0, 0.75 - category.correctAnswerPercentage)
            
            // Estimate questions needed to cover the gap
            let questionsToImprove = Int(Double(category.questionsAnswered) * gapToMastery)
            
            // ~2 minutes per question to improve (review + practice)
            let minutesNeeded = questionsToImprove * 2
            
            // Convert to hours (min 1 hour per weak category)
            totalHours += max(1, minutesNeeded / 60)
        }
        
        return totalHours
    }
}