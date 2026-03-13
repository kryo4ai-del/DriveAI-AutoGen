import Foundation

@MainActor
class CategorySelectionViewModel: ObservableObject {
    @Published var categories: [TrainingCategory] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    private let dataService: PremiumDefaultLocalDataService
    
    var filteredCategories: [TrainingCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(dataService: PremiumDefaultLocalDataService = .shared) {
        self.dataService = dataService
    }
    
    func loadCategories() {
        isLoading = true
        
        Task {
            do {
                let premiumCategories = try await dataService.fetchCategories()
                self.categories = premiumCategories.map { cat in
                    TrainingCategory(
                        id: cat.id,
                        name: cat.name,
                        description: cat.description,
                        questionCount: cat.questionCount,
                        iconName: "book.fill"
                    )
                }
            } catch {
                self.categories = []
            }
            self.isLoading = false
        }
    }
}
