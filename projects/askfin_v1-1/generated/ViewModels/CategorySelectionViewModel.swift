import Foundation

class CategorySelectionViewModel: ObservableObject {
    @Published var categories: [TrainingCategory] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    private let dataService: LocalDataServiceProtocol
    
    var filteredCategories: [TrainingCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(dataService: LocalDataServiceProtocol = LocalDataService.shared) {
        self.dataService = dataService
    }
    
    func loadCategories() {
        isLoading = true
        
        Task {
            do {
                self.categories = try await dataService.fetchCategories()
            } catch {
                self.categories = []
            }
            self.isLoading = false
        }
    }
}