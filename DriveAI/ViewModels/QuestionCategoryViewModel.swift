import Foundation

class QuestionCategoryViewModel: ObservableObject {
    @Published var categories: [QuestionCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil // Error handling

    init() {
        fetchCategories()
    }

    private func fetchCategories() {
        isLoading = true
        errorMessage = nil // Reset error message
        LocalDataService.shared.loadCategories { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                    case .success(let categories):
                        self.categories = categories
                    case .failure(let error):
                        print("Failed to load categories: \(error)")
                        self.errorMessage = "Fehler beim Laden der Kategorien." // "Error loading categories."
                }
            }
        }
    }
}