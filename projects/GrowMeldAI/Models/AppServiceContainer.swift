import SwiftUI

class AppServiceContainer: ObservableObject {
    let questionService: QuestionServiceProtocol
    let userProgressService: UserProgressServiceProtocol
    let localDataService: LocalDataServiceProtocol
    let examService: ExamSimulationServiceProtocol

    init() {
        let dataService = LocalDataService()
        self.localDataService = dataService
        self.questionService = QuestionService(dataService: dataService)
        self.userProgressService = UserProgressService()
        self.examService = ExamSimulationService()
    }
}