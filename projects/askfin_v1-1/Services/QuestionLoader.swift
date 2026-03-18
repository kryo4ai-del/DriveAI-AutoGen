import Foundation

struct QuestionEntry: Codable {
    let id: String
    let topic: String
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let fehlerpunkte: Int
}

final class QuestionLoader {
    static let shared = QuestionLoader()

    private(set) var entries: [QuestionEntry] = []

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([QuestionEntry].self, from: data)
        else { return }
        entries = decoded
    }

    func examQuestions(count: Int) -> [ExamQuestion] {
        entries.shuffled().prefix(count).map { entry in
            ExamQuestion(
                id: UUID(),
                questionText: entry.text,
                options: entry.options,
                correctAnswerIndex: entry.correctIndex,
                topic: TopicArea(rawValue: entry.topic) ?? .general,
                questionType: .recall,
                fehlerpunkteCategory: (TopicArea(rawValue: entry.topic) ?? .general).fehlerpunkteCategory,
                explanation: entry.explanation
            )
        }
    }

    func sessionQuestion(for topic: TopicArea, revealMode: RevealMode) -> SessionQuestion? {
        let matching = entries.filter { $0.topic == topic.rawValue }
        guard let entry = matching.randomElement() else { return nil }

        let options = SwipeDirection.allCases.enumerated().map { index, dir in
            AnswerOption(
                text: index < entry.options.count ? entry.options[index] : "—",
                swipeDirection: dir
            )
        }

        return SessionQuestion(
            text: entry.text,
            options: options,
            correctIndex: entry.correctIndex,
            topic: topic,
            questionType: .recall,
            explanation: entry.explanation,
            revealMode: revealMode
        )
    }
}
