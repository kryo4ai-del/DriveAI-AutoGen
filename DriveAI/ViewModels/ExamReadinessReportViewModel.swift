@MainActor
class ExamReadinessReportViewModel: ObservableObject {
    @Published var report: ExamReadinessReport?
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let calculationService: ReadinessCalculationService
    private let userDefaults: UserDefaults
    
    private static let reportCacheKey = "exam_readiness_report_cache"
    private static let cacheValidityHours: TimeInterval = 1
    
    init(
        calculationService: ReadinessCalculationService = ReadinessCalculationService(
            dataService: LocalDataService.shared
        ),
        userDefaults: UserDefaults = .standard
    ) {
        self.calculationService = calculationService
        self.userDefaults = userDefaults
        loadCachedReportIfFresh()
    }
    
    // MARK: - Public Methods
    
    func loadReport() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let newReport = calculationService.generateFullReport()
            self.report = newReport
            cacheReport(newReport)
        } catch {
            self.error = AppError.readinessCalculationFailed(error)
        }
    }
    
    func refreshReport() async {
        await loadReport()
    }
    
    // MARK: - Private Methods
    
    /// Load cache only if timestamp is fresh (< 1 hour old)
    private func loadCachedReportIfFresh() {
        guard let data = userDefaults.data(forKey: Self.reportCacheKey),
              let cached = try? JSONDecoder().decode(ExamReadinessReport.self, from: data) else {
            return
        }
        
        let hoursSinceGeneration = Date().timeIntervalSince(cached.generatedAt) / 3600
        
        // Only use cache if recent enough
        if hoursSinceGeneration < Self.cacheValidityHours {
            self.report = cached
        }
        // Otherwise, report stays nil → forces fresh load
    }
    
    private func cacheReport(_ report: ExamReadinessReport) {
        if let encoded = try? JSONEncoder().encode(report) {
            userDefaults.set(encoded, forKey: Self.reportCacheKey)
        }
    }
}