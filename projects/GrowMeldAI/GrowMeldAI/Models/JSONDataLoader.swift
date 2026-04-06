// MARK: - Services/Persistence/JSONDataLoader.swift
import Foundation

final class JSONDataLoader {
    func loadQuestions() async throws -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw NSError(domain: "JSONDataLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "questions.json not found"])
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Question].self, from: data)
    }
    
    func loadCategories() async throws -> [Category] {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            throw NSError(domain: "JSONDataLoader", code: -2, userInfo: [NSLocalizedDescriptionKey: "categories.json not found"])
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        return try decoder.decode([Category].self, from: data)
    }
}