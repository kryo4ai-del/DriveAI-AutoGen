// App/Startup/DatabaseSeeding.swift
@MainActor
final class DatabaseSeeding {
    private static let logger = Logger(category: "DatabaseSeeding")
    
    static func seedIfNeeded(service: LocalDataService) async {
        let persistence = PersistenceService.shared
        
        guard !persistence.isDatabaseSeeded else {
            logger.debug("Database already seeded")
            return
        }
        
        do {
            logger.info("Starting database seed...")
            
            guard let jsonAsset = NSDataAsset(name: "questions") else {
                logger.error("questions.json not found in Assets")
                return
            }
            
            try await service.importQuestionsFromJSON(jsonAsset.data)
            persistence.markDatabaseAsSeeded()
            
            logger.info("Database seeded successfully")
        } catch {
            logger.error("Failed to seed database: \(error)")
            // Don't crash — let user retry
        }
    }
}

// App/DriveAIApp.swift
@main

// Core/Services/LocalDataService.swift (add this method)
nonisolated func importQuestionsFromJSON(_ data: Data) async throws {
    let decoder = JSONDecoder()
    let importedData = try decoder.decode(
        DatabaseSnapshot.self,
        from: data
    )
    
    try await dbQueue.write { db in
        for category in importedData.categories {
            try category.insert(db)
        }
        
        for question in importedData.questions {
            try question.insert(db)
        }
        
        for answer in importedData.answers {
            try answer.insert(db)
        }
    }
}

// Structure for JSON import:
struct DatabaseSnapshot: Codable {
    let categories: [Category]
    let questions: [Question]
    let answers: [Answer]
}