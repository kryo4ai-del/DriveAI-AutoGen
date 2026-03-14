@MainActor
final class StatisticsService: ObservableObject {
    static let shared = StatisticsService()
    
    @Published private(set) var allResults: [SimulationResult] = []
    @Published private(set) var readiness: ExamReadiness = .preview
    @Published var dataLoadError: DataLoadError?
    
    private let persistenceService: ResultsPersistenceService
    private let readinessCalculator: ReadinessCalculator
    
    init(
        persistenceService: ResultsPersistenceService = .init(),
        readinessCalculator: ReadinessCalculator = .init()
    ) {
        self.persistenceService = persistenceService
        self.readinessCalculator = readinessCalculator
        
        Task { await loadResults() }
    }
    
    @MainActor
    func saveSimulationResult(_ result: SimulationResult) async throws {
        allResults.insert(result, at: 0)
        try persistenceService.save(allResults)
        updateReadiness()
    }
    
    @MainActor
    private func loadResults() async {
        do {
            allResults = try persistenceService.load()
            updateReadiness()
            dataLoadError = nil
        } catch {
            dataLoadError = DataLoadError.decodingFailed(error)
            allResults = []
        }
    }
    
    @MainActor
    private func updateReadiness() {
        readiness = readinessCalculator.calculate(from: allResults)
    }
}

enum DataLoadError: LocalizedError {
    case decodingFailed(Error)
    
    var errorDescription: String? {
        "Deine Ergebnisse konnten nicht geladen werden."
    }
}