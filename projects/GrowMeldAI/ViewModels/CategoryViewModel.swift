@MainActor
class CategoryViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let dataService: LocalDataService
    
    func loadQuestions(for category: Category) {
        isLoading = true
        Task {
            do {
                self.questions = try await dataService.loadQuestions(for: category.id)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}