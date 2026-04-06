@MainActor
final class CompliancePresentationViewModel: ObservableObject {
    @Published var currentSection: ComplianceSection = .intro
    @Published var sections: [ComplianceSection] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Transient state only — consent is managed by AppConsentManager
    @Published var exportProgress: Double = 0
    
    private let dataService: ComplianceDataService
    private let exportService: DataExportService
    
    init(dataService: ComplianceDataService,
         exportService: DataExportService) {
        self.dataService = dataService
        self.exportService = exportService
        Task { await loadSections() }
    }
    
    func loadSections() async {
        isLoading = true
        defer { isLoading = false }
        sections = await dataService.fetchSections()
    }
    
    func nextSection() {
        if let currentIndex = sections.firstIndex(where: { $0.id == currentSection.id }),
           currentIndex + 1 < sections.count {
            currentSection = sections[currentIndex + 1]
        }
    }
    
    func exportData() async {
        do {
            for try await progress in exportService.generateExport() {
                self.exportProgress = progress
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}