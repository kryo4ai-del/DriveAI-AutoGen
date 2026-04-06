import SwiftUI

class AppServiceContainer: ObservableObject {
    let questionService: QuestionServiceProtocol
    let userProgressService: UserProgressServiceProtocol
    let localDataService: LocalDataServiceProtocol
    let examService: ExamSimulationServiceProtocol
    
    init() {
        self.localDataService = LocalDataService()
        self.questionService = QuestionService(dataService: localDataService)
        self.userProgressService = UserProgressService()
        self.examService = ExamSimulationService()
    }
}

@main
struct DriveAIApp: App {
    @StateObject private var serviceContainer = AppServiceContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serviceContainer)
        }
    }
}