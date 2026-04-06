// Create proper test protocols
protocol MockableLocalDataService: LocalDataService {}

class DataServiceMock: MockableLocalDataService {
    var loadQuestionCallCount = 0
    var recordAnswerCallCount = 0
    var shouldThrowError: DataServiceError?
    
    func loadQuestion(id: String) throws -> Question {
        loadQuestionCallCount += 1
        if let error = shouldThrowError { throw error }
        return Question(/* mock data */)
    }
    
    // ... other methods
}

// Test the ViewModel