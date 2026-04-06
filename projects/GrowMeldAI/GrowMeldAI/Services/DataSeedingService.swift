// Services/DataSeedingService.swift
final class DataSeedingService {
    private let dbManager: DatabaseManager
    private let userDefaults: UserDefaults
    
    private let seedingKey = "com.driveai.seeding.complete"
    
    init(dbManager: DatabaseManager, userDefaults: UserDefaults = .standard) {
        self.dbManager = dbManager
        self.userDefaults = userDefaults
    }
    
    func seedIfNeeded() async throws {
        guard !userDefaults.bool(forKey: seedingKey) else { return }
        
        // Load bundled JSON
        guard let url = Bundle.main.url(forResource: "questions_de", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw DataSeedingError.bundledFileNotFound
        }
        
        let questions = try JSONDecoder().decode([Question].self, from: data)
        
        // Seed to database
        for question in questions {
            try await dbManager.insertQuestion(question)
        }
        
        userDefaults.set(true, forKey: seedingKey)
    }
    
    enum DataSeedingError: LocalizedError {
        case bundledFileNotFound
        
        var errorDescription: String? {
            "Could not locate bundled questions file"
        }
    }
}