// ViewModel Template
@MainActor
class ExampleViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var errorMessage: String?
    
    private let service: ExampleService
    
    init(service: ExampleService = .shared) {
        self.service = service
    }
    
    @MainActor
    func loadData() async {
        state = .loading
        do {
            let data = try await service.fetchData()
            self.state = .loaded(data)
        } catch {
            self.errorMessage = error.localizedDescription
            self.state = .error(error)
        }
    }
}

// State enum for type-safe UI bindings
enum ViewState {
    case idle
    case loading
    case loaded(Data)
    case error(Error)
}