import Foundation

class QuestionParsingEngine {
    private let dataService: LocalDataService
    private var questions: [Question] = []
    
    init(dataService: LocalDataService = LocalDataService()) {
        self.dataService = dataService
        let result = dataService.loadQuestions(from: "questions")

        switch result {
        case .success(let questions):
            self.questions = questions
        case .failure(let error):
            print("Failed to load questions: \(error)") // Possibly replace with proper logging
        }
    }
    
    func getAllQuestions() -> [Question] {
        return questions
    }
}