class AppServiceContainer: ObservableObject {
    let questionService: QuestionServiceProtocol
    let userProgressService: UserProgressServiceProtocol
    let localDataService: LocalDataServiceProtocol
    let examService: ExamSimulationServiceProtocol
    
    init() {
        self.localDataService = LocalDataService()
        self.questionService = QuestionService(dataService: localDataService)
        // ...
    }
}

// In DriveAIApp
@main