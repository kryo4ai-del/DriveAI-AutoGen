// Base pattern (all ViewModels follow this)
@MainActor
class BaseQuizViewModel: ObservableObject {
    // INPUTS
    @Published var selectedAnswerId: String?
    @Published var currentQuestionIndex: Int = 0
    
    // OUTPUTS
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userProgress: UserProgress?
    
    // DEPENDENCIES
    let dataService: LocalDataService
    let storageService: LocalStorageService
    
    init(dataService: LocalDataService, storageService: LocalStorageService) {
        self.dataService = dataService
        self.storageService = storageService
    }
    
    // ACTIONS
    func loadQuestions(categoryId: String) async {
        isLoading = true
        do {
            questions = try await dataService.fetchQuestions(categoryId: categoryId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}