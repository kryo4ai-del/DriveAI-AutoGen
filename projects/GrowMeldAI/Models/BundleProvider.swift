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
                text: "What is the recommended daily water intake for adults?",
                answers: [
                    QuizAnswer(id: "q1a1", text: "1 liter"),
                    QuizAnswer(id: "q1a2", text: "2 liters"),
                    QuizAnswer(id: "q1a3", text: "3 liters"),
                    QuizAnswer(id: "q1a4", text: "4 liters")
                ],
                correctAnswerID: "q1a2"
            ),
            QuizQuestion(
                id: "q2",
                text: "Which macronutrient provides 4 calories per gram?",
                answers: [
                    QuizAnswer(id: "q2a1", text: "Fat"),
                    QuizAnswer(id: "q2a2", text: "Protein"),
                    QuizAnswer(id: "q2a3", text: "Carbohydrates"),
                    QuizAnswer(id: "q2a4", text: "Both Protein and Carbohydrates")
                ],
                correctAnswerID: "q2a4"
            ),
            QuizQuestion(
                id: "q3",
                text: "How many hours of sleep do adults generally need per night?",
                answers: [
                    QuizAnswer(id: "q3a1", text: "5-6 hours"),
                    QuizAnswer(id: "q3a2", text: "6-7 hours"),
                    QuizAnswer(id: "q3a3", text: "7-9 hours"),
                    QuizAnswer(id: "q3a4", text: "10+ hours")
                ],
                correctAnswerID: "q3a3"
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
            print("[BundleProvider] ✗ Failed to load string \(fileName).\(ext): \(error)")
            return nil
        }
    }
}

// MARK: - QuizAnswer

struct QuizAnswer: Codable, Identifiable {
    let id: String
    let text: String
}

// MARK: - QuizQuestion

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let answers: [QuizAnswer]
    let correctAnswerID: String
}