import Foundation

@Observable
final class QuestionListViewModel: BaseViewModel {
    private let repository: QuestionRepositoryProtocol
    private let persistenceService: PersistenceService
    
    let categoryId: String
    let categoryName: String
    
    var questions: [Question] = []
    var currentIndex: Int = 0
    var answeredCount: Int = 0
    
    init(
        categoryId: String,
        categoryName: String,
        repository: QuestionRepositoryProtocol = QuestionRepository(),
        persistenceService: PersistenceService = .shared
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.repository = repository
        self.persistenceService = persistenceService
        super.init()
    }
    
    @MainActor
    func loadQuestions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            questions = try await repository.fetchQuestions(forCategory: categoryId)
        } catch {
            setError(error)
        }
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progressText: String {
        "\(currentIndex + 1) von \(questions.count)"
    }
    
    var progress: Double {
        guard questions.count > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }
    
    func moveToNextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        }
    }
    
    func canMoveNext() -> Bool {
        currentIndex < questions.count - 1
    }
    
    func recordAnswerCorrect() {
        answeredCount += 1
        var progress = persistenceService.loadCategoryProgress(id: categoryId)
            ?? CategoryProgress(id: categoryId, name: categoryName, questionsAnswered: 0, questionsCorrect: 0)
        
        progress.questionsAnswered += 1
        progress.questionsCorrect += 1
        
        persistenceService.saveCategoryProgress(progress)
    }
    
    func recordAnswerIncorrect() {
        answeredCount += 1
        var progress = persistenceService.loadCategoryProgress(id: categoryId)
            ?? CategoryProgress(id: categoryId, name: categoryName, questionsAnswered: 0, questionsCorrect: 0)
        
        progress.questionsAnswered += 1
        
        persistenceService.saveCategoryProgress(progress)
    }
}