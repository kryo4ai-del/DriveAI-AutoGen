import Foundation

class QuestionParsingEngine {
    private let dataService: LocalDataService
    private var questions: [Question] = []

    init(dataService: LocalDataService = LocalDataService()) {
        self.dataService = dataService
        self.questions = dataService.loadQuestions()
    }

    func getAllQuestions() -> [Question] {
        return questions
    }
}
