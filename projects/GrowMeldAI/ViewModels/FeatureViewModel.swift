class FeatureViewModel: ObservableObject {
    // MARK: - Published State
    @Published var state: FeatureState = .idle
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // MARK: - Private Dependencies
    private let dataService: LocalDataService
    private let logger: Logger
    
    // MARK: - Init
    init(dataService: LocalDataService = SQLiteDataService()) {
        self.dataService = dataService
        self.logger = Logger(subsystem: "com.driveai.feature", category: "FeatureViewModel")
    }
    
    // MARK: - Public Methods (User Actions)
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try dataService.loadSomething()
            self.state = .loaded(result)
        } catch {
            self.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
            self.state = .error
            logger.error("Failed to load: \(error)")
        }
        
        isLoading = false
    }
}

enum FeatureState {
    case idle
    case loading
    case loaded(Data)
    case error
}