import Foundation
import Combine

@MainActor
final class QuizSelectionViewModel: ObservableObject {
    @Published var selectedLicenseType: LicenseType?
    @Published var selectedTopic: TopicArea?
    @Published var selectedDifficulty: Difficulty?
    
    @Published var filteredQuizzes: [Quiz] = []
    @Published var userProgress: [UUID: QuizProgress] = [:]
    @Published var recentQuizIds: [UUID] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedQuiz: Quiz?
    
    private let quizDataService: QuizDataService
    private let userSession: UserSession
    private var cancellables = Set<AnyCancellable>()
    
    init(
        quizDataService: QuizDataService = .shared,
        userSession: UserSession
    ) {
        self.quizDataService = quizDataService
        self.userSession = userSession
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen to filter changes
        Publishers.CombineLatest3(
            $selectedLicenseType,
            $selectedTopic,
            $selectedDifficulty
        )
        .debounce(for: 0.2, scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.applyFilters()
        }
        .store(in: &cancellables)
        
        // Listen to quiz data service
        quizDataService.$allQuizzes
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        quizDataService.$isLoading
            .assign(to: &$isLoading)
        
        // Listen to user session
        userSession.$userProgress
            .assign(to: &$userProgress)
        
        userSession.$recentQuizzes
            .assign(to: &$recentQuizIds)
    }
    
    func applyFilters() {
        filteredQuizzes = quizDataService.filter(
            by: selectedLicenseType,
            topic: selectedTopic,
            difficulty: selectedDifficulty
        )
    }
    
    func getProgressBadge(for quiz: Quiz) -> ProgressBadge? {
        guard let progress = userProgress[quiz.id], !progress.attempts.isEmpty else {
            return nil
        }
        
        return ProgressBadge(
            score: progress.bestScore,
            attempts: progress.completionCount,
            isPass: progress.bestScore >= 70
        )
    }
    
    func shouldShowRecommendation(for quiz: Quiz) -> Bool {
        guard let progress = userProgress[quiz.id] else { return false }
        return progress.shouldReview
    }
    
    func selectQuiz(_ quiz: Quiz) {
        selectedQuiz = quiz
    }
    
    var completedQuizCount: Int {
        userProgress.count
    }
    
    var totalQuizCount: Int {
        quizDataService.allQuizzes.count
    }
}

struct ProgressBadge {
    let score: Double
    let attempts: Int
    let isPass: Bool
}