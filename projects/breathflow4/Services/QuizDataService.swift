import Foundation
import Combine

@MainActor
final class QuizDataService: ObservableObject {
    @Published var allQuizzes: [Quiz] = []
    @Published var isLoading = false
    @Published var error: QuizError?
    
    enum QuizError: LocalizedError {
        case loadingFailed(String)
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .loadingFailed(let msg): return msg
            case .invalidData: return "Invalid quiz data"
            }
        }
    }
    
    static let shared = QuizDataService()
    
    private init() {
        loadQuizzes()
    }
    
    func loadQuizzes() {
        isLoading = true
        
        // In production: fetch from API or local JSON bundle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.allQuizzes = Self.generateMockQuizzes()
            self?.isLoading = false
        }
    }
    
    func filter(
        by licenseType: LicenseType?,
        topic: TopicArea?,
        difficulty: Difficulty?
    ) -> [Quiz] {
        allQuizzes.filter { quiz in
            let typeMatch = licenseType == nil || quiz.category == licenseType
            let topicMatch = topic == nil || quiz.topicArea == topic
            let diffMatch = difficulty == nil || quiz.difficulty == difficulty
            return typeMatch && topicMatch && diffMatch
        }
    }
    
    // MARK: - Mock Data Generation
    
    private static func generateMockQuizzes() -> [Quiz] {
        var quizzes: [Quiz] = []
        
        for licenseType in LicenseType.allCases {
            for topic in TopicArea.allCases {
                for difficulty in Difficulty.allCases {
                    let quiz = Quiz(
                        id: UUID(),
                        title: "\(topic.displayName) - \(difficulty.displayName)",
                        category: licenseType,
                        difficulty: difficulty,
                        topicArea: topic,
                        questionCount: Int.random(in: 15...25),
                        estimatedDurationSeconds: TimeInterval.random(in: 600...1800),
                        description: "Test your knowledge of \(topic.displayName.lowercased())",
                        questions: generateMockQuestions(count: Int.random(in: 15...25))
                    )
                    quizzes.append(quiz)
                }
            }
        }
        
        return quizzes
    }
    
    private static func generateMockQuestions(count: Int) -> [Question] {
        (0..<count).map { index in
            Question(
                id: UUID(),
                quizId: UUID(),
                text: "Sample question \(index + 1): What is the correct action?",
                options: ["Option A", "Option B", "Option C", "Option D"],
                correctAnswerIndex: Int.random(in: 0...3),
                difficulty: Difficulty.allCases.randomElement()!,
                explanation: "This is the correct answer because..."
            )
        }
    }
}