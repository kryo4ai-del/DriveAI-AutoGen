import Foundation

class LocalAIFallbackService: AIServiceProtocol {
    private let localDataService: LocalDataServiceProtocol
    private let _statePublisher = CurrentValueSubject<ServiceState, Never>(.ready)
    
    var statePublisher: AnyPublisher<ServiceState, Never> {
        _statePublisher.eraseToAnyPublisher()
    }
    
    var state: ServiceState {
        _statePublisher.value
    }
    
    init(localDataService: LocalDataServiceProtocol) {
        self.localDataService = localDataService
    }
    
    func fetchHint(for question: Question) async throws -> AIHint {
        // Return official explanation from local database
        let explanation = question.explanation ?? "Keine Erklärung verfügbar. Weitere Informationen erhalten Sie von offiziellen Quellen."
        
        return AIHint(
            text: explanation,
            source: question.explanation != nil ? .official : .fallback,
            confidence: 1.0
        )
    }
    
    func rankQuestions(by category: Category) async throws -> [Question] {
        // Return sequential order (no AI ranking)
        let allQuestions = localDataService.fetchQuestionsByCategory(category)
        return allQuestions.sorted { $0.id < $1.id }
    }
    
    func adjustDifficulty(based progress: ExamProgress) async throws -> DifficultyLevel {
        // Static difficulty based on category score
        let categoryId = progress.currentCategory?.id ?? ""
        let score = progress.categoryScores[categoryId] ?? 0
        
        if score > 80 {
            return .hard
        } else if score > 60 {
            return .medium
        } else {
            return .easy
        }
    }
}