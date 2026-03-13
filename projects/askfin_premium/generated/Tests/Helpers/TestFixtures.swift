import Foundation
@testable import DriveAI

enum TestFixtures {

    static func makeOptions(
        texts: [String] = ["Antwort A", "Antwort B", "Antwort C", "Antwort D"]
    ) -> [AnswerOption] {
        zip(texts, SwipeDirection.allCases).map {
            AnswerOption(text: $0, swipeDirection: $1)
        }
    }

    static func makeQuestion(
        text: String = "Testfrage",
        correctIndex: Int = 0,
        topic: TopicArea = .rightOfWay,
        questionType: QuestionType = .recall,
        explanation: String = "Weil die Vorfahrtsregel es vorschreibt.",
        revealMode: RevealMode = .immediate
    ) -> SessionQuestion {
        SessionQuestion(
            text: text,
            options: makeOptions(),
            correctIndex: correctIndex,
            topic: topic,
            questionType: questionType,
            explanation: explanation,
            revealMode: revealMode
        )!
    }

    static func makeCompetence(
        topic: TopicArea = .rightOfWay,
        totalAnswers: Int = 10,
        correctAnswers: Int = 8,
        weightedAccuracy: Double = 0.80
    ) -> TopicCompetence {
        TopicCompetence(
            topic: topic,
            totalAnswers: totalAnswers,
            correctAnswers: correctAnswers,
            weightedAccuracy: weightedAccuracy
        )
    }

    static func makeSpacingItem(
        topic: TopicArea = .rightOfWay,
        consecutiveCorrect: Int = 0,
        daysUntilDue: Int = 0
    ) -> SpacingItem {
        SpacingItem(
            topic: topic,
            consecutiveCorrect: consecutiveCorrect,
            nextReviewDate: Calendar.current.date(
                byAdding: .day, value: daysUntilDue, to: Date()
            ) ?? Date()
        )
    }

    static func makeResult(
        topic: TopicArea = .rightOfWay,
        wasCorrect: Bool = true,
        selectedDirection: SwipeDirection = .right
    )

[test_generator]
# DriveAI Training Mode — Complete Test Suite

All tests grounded in the final implementation. Each file is complete and independently compilable.

---

## `Tests/Helpers/TestFixtures.swift`
