final class InMemoryDataService: LocalDataService {
    private var sampleQuestions: [Question] = []
    private var userAnswers: [String: Int] = [:]  // questionId: answerIndex
    private var categoryProgress: [String: UserProgress] = [:]
    
    init() {
        setupSampleData()
    }
    
    private func setupSampleData() {
        sampleQuestions = [
            Question(
                id: "q001",
                category: Category.allCategories[0],
                text: "Was bedeutet dieses Verkehrszeichen?",
                imageURL: nil,
                options: ["Vorfahrtsstraße", "Vorfahrt gewähren", "Stopp", "Einfahrt verboten"],
                correctAnswer: 1,
                difficulty: .easy,
                explanation: "Das Zeichen bedeutet 'Vorfahrt gewähren'. Du musst anderen Fahrzeugen die Vorfahrt geben."
            ),
            Question(
                id: "q002",
                category: Category.allCategories[1],
                text: "An einer Kreuzung ohne Ampel: Wer hat Vorfahrt?",
                imageURL: nil,
                options: ["Der, der zuerst fährt", "Von rechts kommendes Fahrzeug", "Der Stärkere", "Der, der schneller ist"],
                correctAnswer: 1,
                difficulty: .medium,
                explanation: "Fahrzeuge von rechts haben Vorfahrt. Das ist die 'Rechts-vor-Links-Regel'."
            ),
            Question(
                id: "q003",
                category: Category.allCategories[2],
                text: "Was kostet zu schnelles Fahren in der Stadt?",
                imageURL: nil,
                options: ["10 EUR", "30 EUR", "100 EUR", "Abhängig von der Geschwindigkeit"],
                correctAnswer: 3,
                difficulty: .hard,
                explanation: "Das Bußgeld hängt davon ab, wie viel zu schnell gefahren wurde. 5-10 km/h Übergeschwindigkeit kosten unterschiedlich als 20+ km/h."
            ),
        ]
    }
    
    func loadQuestion(id: String) throws -> Question {
        guard let question = sampleQuestions.first(where: { $0.id == id }) else {
            throw DataServiceError.questionNotFound
        }
        return question
    }
    
    func loadRandomQuestion(category: Category, exclude: [String]) throws -> Question {
        let available = sampleQuestions.filter {
            $0.category.id == category.id && !exclude.contains($0.id)
        }
        guard let random = available.randomElement() else {
            throw DataServiceError.questionNotFound
        }
        return random
    }
    
    func loadQuestionsBatch(category: Category, count: Int, exclude: [String]) throws -> [Question] {
        let available = sampleQuestions.filter {
            $0.category.id == category.id && !exclude.contains($0.id)
        }
        return Array(available.shuffled().prefix(count))
    }
    
    func listCategories() throws -> [Category] {
        return Category.allCategories
    }
    
    func recordAnswer(questionId: String, userAnswer: Int, categoryId: String) throws -> Bool {
        guard let question = sampleQuestions.first(where: { $0.id == questionId }) else {
            throw DataServiceError.questionNotFound
        }
        
        userAnswers[questionId] = userAnswer
        let isCorrect = userAnswer == question.correctAnswer
        
        // Update category progress
        var progress = categoryProgress[categoryId] ?? UserProgress(
            categoryId: categoryId,
            totalQuestions: sampleQuestions.filter { $0.category.id == categoryId }.count,
            answeredQuestions: 0,
            correctAnswers: 0
        )
        progress.answeredQuestions += 1
        if isCorrect { progress.correctAnswers += 1 }
        categoryProgress[categoryId] = progress
        
        return isCorrect
    }
    
    func getProgress(categoryId: String) throws -> UserProgress {
        guard let progress = categoryProgress[categoryId] else {
            throw DataServiceError.categoryNotFound
        }
        return progress
    }
    
    func getAllProgress() throws -> [UserProgress] {
        return Array(categoryProgress.values)
    }
    
    func startExam() throws -> String {
        return UUID().uuidString
    }
    
    func recordExamAnswer(examId: String, questionId: String, answer: Int) throws {
        userAnswers[questionId] = answer
    }
    
    func completeExam(examId: String) throws -> (score: Int, passed: Bool, breakdown: [String: Int]) {
        let score = userAnswers.values.count  // Simplified: count answers
        return (score: score, passed: score >= 24, breakdown: [:])
    }
    
    func getExamHistory() throws -> [ExamAttempt] {
        return []
    }
}