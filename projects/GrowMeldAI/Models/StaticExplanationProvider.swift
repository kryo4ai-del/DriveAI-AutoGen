// Models/StaticExplanationProvider.swift

import Foundation

// MARK: - Static Explanation Model

struct StaticExplanationResult {
    let questionId: Int
    let text: String
    let source: String
    let isAuthoritative: Bool
}

// MARK: - Static Explanation Provider

class StaticExplanationProvider {

    private let staticExplanations: [Int: String]  // questionId → explanation

    init() {
        // Load from Resources/StaticExplanations.json
        // Bundled at build time; guaranteed available offline
        self.staticExplanations = StaticExplanationProvider.loadExplanations()
    }

    func explanation(for questionId: Int) -> StaticExplanationResult {
        let text = staticExplanations[questionId]
            ?? "Explanation not available. Please use official materials."

        return StaticExplanationResult(
            questionId: questionId,
            text: text,
            source: "Offline",
            isAuthoritative: false  // Always mark static as non-authoritative
        )
    }

    // MARK: - Private Helpers

    private static func loadExplanations() -> [Int: String] {
        guard let url = Bundle.main.url(forResource: "StaticExplanations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("[StaticExplanationProvider] Warning: StaticExplanations.json not found in bundle.")
            return [:]
        }

        do {
            let decoded = try JSONDecoder().decode([Int: String].self, from: data)
            return decoded
        } catch {
            print("[StaticExplanationProvider] Error decoding StaticExplanations.json: \(error)")
            return [:]
        }
    }
}