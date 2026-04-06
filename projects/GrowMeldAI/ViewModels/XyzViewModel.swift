// ✅ CORE VIEWMODEL TEMPLATE (All ViewModels inherit this pattern)

@MainActor
final class XyzViewModel: ObservableObject {
    // MARK: - @Published State (UI Observable)
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    // ... domain-specific @Published properties
    
    // MARK: - Private Services (Injected)
    private let service1: Service1Protocol
    private let service2: Service2Protocol
    
    // MARK: - Initialization
    init(service1: Service1Protocol, service2: Service2Protocol) {
        self.service1 = service1
        self.service2 = service2
        
        // Kick off async data loading
        Task {
            await loadData()
        }
    }
    
    // MARK: - Public Methods (Called by Views)
    nonisolated func somePublicAction() {
        Task {
            await handleAction()
        }
    }
    
    // MARK: - Private Methods (Internal Logic)
    @MainActor
    private func loadData() async {
        loadingState = .loading
        
        do {
            // Parallel async/await calls
            async let data1 = service1.fetchData()
            async let data2 = service2.fetchData()
            
            let (result1, result2) = try await (data1, data2)
            
            // Update @Published state atomically
            self.loadingState = .idle
            // ... update @Published properties from results
        } catch {
            self.loadingState = .error(error)
        }
    }
    
    // MARK: - Computed Properties (Derived State)
    var isLoading: Bool {
        if case .loading = loadingState { return true }
        return false
    }
}