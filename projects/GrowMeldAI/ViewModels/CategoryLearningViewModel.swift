// Services/ViewModels/CategoryLearningViewModel.swift
import SwiftUI
import Combine

@MainActor
final class CategoryLearningViewModel: ObservableObject {
    // MARK: - Published State
    @Published var categoryId: String
    @Published var masteryCurve: [MasterySnapshot] = []
    @Published var strugglingQuestions: [Question] = []
    @Published var recommendedNextAction: LearningAction = .review
    @Published var isLoading = false
    @Published var error: MemoryError? = nil
    
    let categoryName: String
    
    // MARK: - Private State
    private let memoryService: MemoryService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        categoryId: String,
        categoryName: String,
        memoryService: MemoryService
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.memoryService = memoryService
    }
    
    // MARK: - Public Methods
    
    func loadCategoryData() async throws {
        await MainActor.run { self.isLoading = true }
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            let questions = memoryService.getQuestionsByCategory(categoryId)
            
            // Compute mastery curve (14-day snapshots)
            let curve = computeMasteryCurve(for: questions)
            
            // Identify struggling questions
            let struggling = questions.filter { question in
                let reviews = memoryService.getReviewsForQuestion(question.id)
                let accuracy = computeAccuracy(from: reviews)
                let reviewCount = reviews.count
                
                // Struggling: < 50% accuracy OR < 3 reviews yet
                return accuracy < 0.5 || reviewCount < 3
            }
            
            // Compute recommended action
            let nextAction = determineNextAction(
                categoryMastery: computeCategoryMastery(questions),
                strugglingCount: struggling.count,
                questionCount: questions.count
            )
            
            await MainActor.run {
                self.masteryCurve = curve
                self.strugglingQuestions = struggling
                self.recommendedNextAction = nextAction
                self.error = nil
            }
        } catch {
            let memoryError = error as? MemoryError ?? .databaseError("Load failed: \(error)")
            await MainActor.run {
                self.error = memoryError
            }
            throw memoryError
        }
    }
    
    func updateMasteryLevel(
        _ questionId: UUID,
        newLevel: MasteryLevel
    ) async throws {
        do {
            try await memoryService.updateMasteryLevel(questionId, level: newLevel)
            
            // Reload to reflect change
            try await loadCategoryData()
        } catch {
            let memoryError = error as? MemoryError ?? .databaseError("Update failed: \(error)")
            await MainActor.run {
                self.error = memoryError
            }
            throw memoryError
        }
    }
    
    // MARK: - Private Helpers
    
    private func computeMasteryCurve(for questions: [Question]) -> [MasterySnapshot] {
        let calendar = Calendar.current
        var snapshots: [MasterySnapshot] = []
        
        let today = calendar.startOfDay(for: Date())
        
        for daysAgo in (0..<14).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            
            let masteryOnDate = questions
                .map { question -> Double in
                    let _ = memoryService.getReviewsForQuestion(question.id)
                        .filter { $0.timestamp <= date }
                    return Double(question.masteryLevel.rawValue)
                }
                .reduce(0, +) / Double(max(questions.count, 1))
            
            snapshots.append(
                MasterySnapshot(date: date, masteryLevel: masteryOnDate)
            )
        }
        
        return snapshots
    }
    
    private func computeCategoryMastery(_ questions: [Question]) -> Double {
        guard !questions.isEmpty else { return 0 }
        return questions
            .map { Double($0.masteryLevel.rawValue) }
            .reduce(0, +) / Double(questions.count)
    }
    
    private func computeAccuracy(from reviews: [ReviewRecord]) -> Double {
        guard !reviews.isEmpty else { return 0 }
        let correctCount = Double(reviews.filter { $0.isCorrect }.count)
        return correctCount / Double(reviews.count)
    }
    
    private func determineNextAction(
        categoryMastery: Double,
        strugglingCount: Int,
        questionCount: Int
    ) -> LearningAction {
        // Priority: struggling questions first
        if strugglingCount > 0 {
            return .reviewStruggling(count: strugglingCount)
        }
        
        // Then by overall mastery
        switch categoryMastery {
        case 0..<0.5:
            return .intensiveFocus
        case 0.5..<0.7:
            return .review
        case 0.7..<0.85:
            return .spaceRepetition
        default:
            return .maintenance
        }
    }
}

// MARK: - Models
struct MasterySnapshot: Identifiable {
    let id = UUID()
    let date: Date
    let masteryLevel: Double
}

enum LearningAction: Equatable {
    case intensiveFocus
    case review
    case spaceRepetition
    case maintenance
    case reviewStruggling(count: Int)
    
    var description: String {
        switch self {
        case .intensiveFocus:
            return "Intensives Lernen erforderlich"
        case .review:
            return "Wiederholung empfohlen"
        case .spaceRepetition:
            return "Regelmäßige Wiederholungen"
        case .maintenance:
            return "Beherrscht - Wartung"
        case .reviewStruggling(let count):
            return "Lernen Sie \(count) schwierige Fragen"
        }
    }
}