import Foundation
import UIKit

@MainActor
final class DatabaseSeeding {

    static func seedIfNeeded() async {
        let defaults = UserDefaults.standard
        let seededKey = "com.growmeldai.databaseSeeded"

        guard !defaults.bool(forKey: seededKey) else {
            print("[DatabaseSeeding] Database already seeded")
            return
        }

        do {
            print("[DatabaseSeeding] Starting database seed...")

            guard let asset = NSDataAsset(name: "questions") else {
                print("[DatabaseSeeding] questions.json not found in Assets")
                return
            }

            try await importQuestionsFromJSON(asset.data)
            defaults.set(true, forKey: seededKey)

            print("[DatabaseSeeding] Database seeded successfully")
        } catch {
            print("[DatabaseSeeding] Failed to seed database: \(error)")
        }
    }

    private static func importQuestionsFromJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        let snapshot = try decoder.decode(DatabaseSnapshot.self, from: data)

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(snapshot)
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("database_snapshot.json")
        try encoded.write(to: fileURL)

        print("[DatabaseSeeding] Imported \(snapshot.categories.count) categories, \(snapshot.questions.count) questions, \(snapshot.answers.count) answers")
    }
}

struct DatabaseSnapshot: Codable {
    let categories: [SeedCategory]
    let questions: [SeedQuestion]
    let answers: [SeedAnswer]
}

struct SeedCategory: Codable {
    let id: Int
    let name: String
}

struct SeedQuestion: Codable {
    let id: Int
    let categoryId: Int
    let text: String
}

struct SeedAnswer: Codable {
    let id: Int
    let questionId: Int
    let text: String
    let isCorrect: Bool
}