@MainActor
final class SimulationResultViewModel: ObservableObject {
    @Published private(set) var result: SimulationResult
    @Published private(set) var readiness: ExamReadiness = .preview
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?
    
    private let statisticsService: StatisticsService
    
    init(
        result: SimulationResult,
        statisticsService: StatisticsService = .shared
    ) {
        self.result = result
        self.statisticsService = statisticsService
        
        Task {
            await self.persistAndUpdateReadiness()
        }
    }
    
    @MainActor
    private func persistAndUpdateReadiness() async {
        defer { isLoading = false }
        
        do {
            try await statisticsService.saveSimulationResult(result)
            // Force refresh readiness after save
            self.readiness = statisticsService.readiness
        } catch {
            errorMessage = "Ergebnis konnte nicht gespeichert werden: \(error.localizedDescription)"
            // Fallback: use cached readiness even if save failed
            self.readiness = statisticsService.readiness
        }
    }
}