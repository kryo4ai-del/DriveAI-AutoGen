#if DEBUG
extension ExamReadinessViewModel {
    static let preview: ExamReadinessViewModel = {
        let service = ExamReadinessService(
            dataService: LocalDataService(),
            progressService: StubUserProgressService(),
            persistenceService: MockTrendPersistenceService()
        )
        let vm = ExamReadinessViewModel(service: service)
        return vm
    }()
}

private struct StubUserProgressService: UserProgressServiceProtocol {
    func getOverallProgress() async throws -> Double { 0.5 }
}
#endif