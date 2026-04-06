@MainActor
class AppViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var currentQuizState: QuizSessionState?
    @Published var isOnboarded: Bool = false
    
    let dataService: LocalDataService
    let storageService: LocalStorageService
    
    init(dataService: LocalDataService, storageService: LocalStorageService) {
        self.dataService = dataService
        self.storageService = storageService
        self.isOnboarded = storageService.isOnboarded
        self.restoreSessionIfNeeded()
    }
    
    private func restoreSessionIfNeeded() {
        // If quiz was in progress, restore it
        if let savedQuizState = try? storageService.getQuizSessionState() {
            currentQuizState = savedQuizState
            navigateTo(.quiz(categoryId: savedQuizState.categoryId))
        }
    }
}

// Add to LocalStorageService
func saveQuizSessionState(_ state: QuizSessionState) throws {
    let data = try JSONEncoder().encode(state)
    defaults.set(data, forKey: "quizSessionState")
}

func getQuizSessionState() throws -> QuizSessionState? {
    guard let data = defaults.data(forKey: "quizSessionState") else { return nil }
    return try JSONDecoder().decode(QuizSessionState.self, from: data)
}

func clearQuizSessionState() {
    defaults.removeObject(forKey: "quizSessionState")
}