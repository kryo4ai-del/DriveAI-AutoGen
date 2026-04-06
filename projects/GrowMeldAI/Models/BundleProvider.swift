import Foundation

// MARK: - BundleProvider

struct BundleProvider {

    // MARK: - Quiz Questions

    static func loadQuizQuestions(from fileName: String = "quiz_questions") -> [QuizQuestion] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("[BundleProvider] ⚠ Could not find \(fileName).json in bundle")
            return defaultQuizQuestions()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let questions = try decoder.decode([QuizQuestion].self, from: data)
            return questions
        } catch {
            print("[BundleProvider] ✗ Failed to decode \(fileName).json: \(error)")
            return defaultQuizQuestions()
        }
    }

    // MARK: - Default Fallback Data

    static func defaultQuizQuestions() -> [QuizQuestion] {
        [
            QuizQuestion(
                id: "q1",
                question: "What is the recommended daily water intake for adults?",
                answers: ["1 liter", "2 liters", "3 liters", "4 liters"],
                correctAnswerIndex: 1,
                explanation: "Most adults need about 2 liters (8 cups) of water per day."
            ),
            QuizQuestion(
                id: "q2",
                question: "Which macronutrient provides 4 calories per gram?",
                answers: ["Fat", "Protein", "Carbohydrates", "Both Protein and Carbohydrates"],
                correctAnswerIndex: 3,
                explanation: "Both protein and carbohydrates provide 4 calories per gram, while fat provides 9."
            ),
            QuizQuestion(
                id: "q3",
                question: "How many hours of sleep do adults generally need per night?",
                answers: ["5–6 hours", "6–7 hours", "7–9 hours", "10+ hours"],
                correctAnswerIndex: 2,
                explanation: "The CDC recommends 7–9 hours of sleep per night for adults."
            )
        ]
    }

    // MARK: - Generic JSON Loader

    static func load<T: Decodable>(_ type: T.Type, from fileName: String, withExtension ext: String = "json") -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("[BundleProvider] ⚠ Resource not found: \(fileName).\(ext)")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[BundleProvider] ✗ Failed to load \(fileName).\(ext): \(error)")
            return nil
        }
    }

    // MARK: - String Loader

    static func loadString(from fileName: String, withExtension ext: String = "txt") -> String? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("[BundleProvider] ⚠ String resource not found: \(fileName).\(ext)")
            return nil
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("[BundleProvider] ✗ Failed to load string from \(fileName).\(ext): \(error)")
            return nil
        }
    }
}