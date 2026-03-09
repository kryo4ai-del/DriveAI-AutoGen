import Combine

class QuestionCategoryViewModel: ObservableObject {
    @Published var categories: [QuestionCategory] = []
    private var localDataService: QuestionCategoryService
    private var cancellables = Set<AnyCancellable>()
    
    init(localDataService: QuestionCategoryService = LocalDataService()) {
        self.localDataService = localDataService
        fetchCategories()
    }

    func fetchCategories() {
        localDataService.fetchQuestionCategories { [weak self] fetchedCategories in
            self?.categories = fetchedCategories
        }
    }
}