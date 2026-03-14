@MainActor
class ExamReadinessReportViewModelTests: XCTestCase {
    var sut: ExamReadinessReportViewModel!
    var mockCalcService: MockReadinessCalculationService!
    var mockDefaults: UserDefaults!
    
    @MainActor
    override func setUp() async throws {
        mockDefaults = UserDefaults(suiteName: #function)!
        mockDefaults.removePersistentDomain(forName: #function)
        
        mockCalcService = MockReadinessCalculationService()
        sut = ExamReadinessReportViewModel(
            calculationService: mockCalcService,
            userDefaults: mockDefaults
        )
    }
    
    @MainActor
    func test_loadCachedReport_ignoresStaleDataOlderThan1Hour() async {
        // Arrange: Cache a report from 2 hours ago
        let staleReport = ExamReadinessReport(
            overallScore: 50,
            categoryBreakdown: [],
            generatedAt: Date(timeIntervalSinceNow: -7200)
        )
        let encoded = try! JSONEncoder().encode(staleReport)
        mockDefaults.set(encoded, forKey: "exam_readiness_report_cache")
        
        // Act: Create new ViewModel (loads cache in init)
        let newVM = ExamReadinessReportViewModel(
            calculationService: mockCalcService,
            userDefaults: mockDefaults
        )
        
        // Assert: Stale cache should NOT be loaded
        await MainActor.run {
            XCTAssertNil(newVM.report, "Stale cache should not be loaded")
        }
    }
    
    @MainActor
    func test_loadCachedReport_usesRecentData() async {
        // Arrange: Cache a report from 30 minutes ago
        let freshReport = ExamReadinessReport(
            overallScore: 75,
            categoryBreakdown: [],
            generatedAt: Date(timeIntervalSinceNow: -1800)
        )
        let encoded = try! JSONEncoder().encode(freshReport)
        mockDefaults.set(encoded, forKey: "exam_readiness_report_cache")
        
        // Act
        let newVM = ExamReadinessReportViewModel(
            calculationService: mockCalcService,
            userDefaults: mockDefaults
        )
        
        // Assert: Fresh cache SHOULD be loaded
        await MainActor.run {
            XCTAssertEqual(newVM.report?.overallScore, 75)
        }
    }
    
    @MainActor
    func test_loadReport_cachesResultAndMakesAvailableImmediately() async {
        // Arrange
        let freshReport = ExamReadinessReport(
            overallScore: 80,
            categoryBreakdown: []
        )
        mockCalcService.reportToReturn = freshReport
        
        // Act
        await sut.loadReport()
        
        // Assert: Report cached
        XCTAssertNotNil(mockDefaults.data(forKey: "exam_readiness_report_cache"))
        XCTAssertEqual(sut.report?.overallScore, 80)
    }
}