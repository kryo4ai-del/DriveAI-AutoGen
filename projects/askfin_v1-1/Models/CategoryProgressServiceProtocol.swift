protocol CategoryProgressServiceProtocol {
    func fetchAllProgress() async throws -> [CategoryProgress]
}