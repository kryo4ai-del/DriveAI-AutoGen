// DTO: Data Transfer Object (minimal contract)
struct QuestionDTO: Codable {
    let id: String
    let text: String
    let categoryId: String
    let answerTexts: [String]
    let correctAnswerIndex: Int
    let explanation: String
}

// Service implementation

// ViewModel converts DTO → Domain Model
extension Question {
    init(from dto: QuestionDTO) throws {
        // Validation + enrichment
        guard !dto.text.isEmpty else {
            throw AppError.invalidQuestion("Fragentext darf nicht leer sein")
        }
        guard dto.answerTexts.count == 4 else {
            throw AppError.invalidQuestion("Frage muss genau 4 Antworten haben")
        }
        
        let answers = dto.answerTexts.enumerated().map { index, text in
            Answer(
                id: UUID(),
                text: text,
                isCorrect: index == dto.correctAnswerIndex,
                explanation: dto.explanation
            )
        }
        
        self.init(
            id: UUID(uuidString: dto.id) ?? UUID(),
            categoryId: UUID(uuidString: dto.categoryId) ?? UUID(),
            text: dto.text,
            answers: answers,
            imageUrl: nil,
            difficulty: 1
        )
    }
}

// Mocking becomes simple:

// Test:
func testQuestionViewModelLoading() async {
    let dto = QuestionDTO(
        id: "q1",
        text: "Test question",
        categoryId: "cat1",
        answerTexts: ["A", "B", "C", "D"],
        correctAnswerIndex: 0,
        explanation: "Explanation"
    )
    let mockService = MockLocalDataService(questionsToReturn: [dto])
    
    let vm = QuestionViewModel(
        categoryId: UUID(),
        dataService: mockService,
        userService: mockUserService
    )
    
    await vm.loadQuestions()
    XCTAssertEqual(vm.state, .displayingQuestion(...))
}