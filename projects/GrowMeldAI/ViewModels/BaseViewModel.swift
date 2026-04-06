// Extract common ViewModel behavior
protocol BaseViewModel: ObservableObject {
    associatedtype Model
    
    @Published var data: Model?
    @Published var isLoading: Bool
    @Published var error: String?
    
    func loadData() async
    func handleError(_ error: Error)
}

// Individual ViewModels conform to protocol, reducing boilerplate