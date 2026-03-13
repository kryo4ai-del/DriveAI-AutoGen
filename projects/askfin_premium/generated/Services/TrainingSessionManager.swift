import Foundation

@MainActor
final class TrainingSessionManager: NSObject {
    
    static let shared = TrainingSessionManager()
    
    private let fileManager = FileManager.default
    private lazy var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private lazy var trainingResultsURL: URL = {
        documentsDirectory.appendingPathComponent("trainingResults")
    }()
    
    override init() {
        super.init()
        try? createDirectoriesIfNeeded()
    }
    
    // MARK: - Persistence
    
    func saveTrainingResult(_ result: TrainingResult) async throws {
        try createDirectoriesIfNeeded()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(result)
        let fileURL = trainingResultsURL.appendingPathComponent("\(result.id.uuidString).json")
        
        try data.write(to: fileURL)
    }
    
    func getTrainingHistory(for categoryId: String, limit: Int = 10) async throws -> [TrainingResult] {
        let fileURLs = try fileManager.contentsOfDirectory(
            at: trainingResultsURL,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        var results: [TrainingResult] = []
        
        for fileURL in fileURLs {
            let data = try Data(contentsOf: fileURL)
            let result = try decoder.decode(TrainingResult.self, from: data)
            results.append(result)
        }
        
        return Array(results.sorted { $0.completedAt > $1.completedAt }.prefix(limit))
    }
    
    func getCategoryStatistics(for categoryId: String) async throws -> CategoryStats {
        let results = try await getTrainingHistory(for: categoryId, limit: 100)
        
        let totalAttempts = results.count
        let averageScore = results.isEmpty ? 0 : results.map { $0.scorePercentage }.reduce(0, +) / Double(results.count)
        let bestScore = results.map { $0.scorePercentage }.max() ?? 0
        let lastAttemptDate = results.first?.completedAt
        
        return CategoryStats(
            categoryId: categoryId,
            categoryName: results.first?.categoryName ?? "",
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            bestScore: bestScore,
            lastAttemptDate: lastAttemptDate,
            totalQuestionsAvailable: 0
        )
    }
    
    // MARK: - Cleanup
    
    private func createDirectoriesIfNeeded() throws {
        if !fileManager.fileExists(atPath: trainingResultsURL.path) {
            try fileManager.createDirectory(
                at: trainingResultsURL,
                withIntermediateDirectories: true
            )
        }
    }
}