import Foundation

/// A single question within a training session.
///
/// Not Codable — questions are rebuilt each session from the question bank.
/// Only SessionResult values are persisted.
struct SessionQuestion: Identifiable {
    let id: UUID
    let text: String
    /// Always exactly 4 elements, one per SwipeDirection.
    let options: [AnswerOption]
    let correctIndex: Int
    let topic: TopicArea
    let questionType: QuestionType
    /// 1–2 sentences connecting the answer to the driving rule.
    let explanation: String
    let revealMode: RevealMode

    var correctOption: AnswerOption { options[correctIndex] }

    func isCorrect(swipeDirection: SwipeDirection) -> Bool {
        correctOption.swipeDirection == swipeDirection
    }

    /// Conceptual distance between selected and correct direction,
    /// measured on SwipeDirection.allCases order — not array position.
    ///
    /// Used by AnswerRevealView to select appropriate copy tone.
    /// Returns 0 when correct (though callers should gate on isCorrect first).
    func missDistance(for selectedDirection: SwipeDirection) -> Int {
        let all = SwipeDirection.allCases
        guard
            let selectedIdx = all.firstIndex(of: selectedDirection),
            let correctIdx  = all.firstIndex(of: correctOption.swipeDirection)
        else { return all.count }
        return abs(selectedIdx - correctIdx)
    }

    /// Failable init — returns nil rather than crashing on invalid input.
    init?(
        id: UUID = UUID(),
        text: String,
        options: [AnswerOption],
        correctIndex: Int,
        topic: TopicArea,
        questionType: QuestionType,
        explanation: String,
        revealMode: RevealMode = .immediate
    ) {
        guard options.count == 4 else {
            assertionFailure("SessionQuestion requires exactly 4 options, got \(options.count)")
            return nil
        }
        guard (0..<4).contains(correctIndex) else {
            assertionFailure("correctIndex \(correctIndex) out of range 0–3")
            return nil
        }
        self.id = id
        self.text = text
        self.options = options
        self.correctIndex = correctIndex
        self.topic = topic
        self.questionType = questionType
        self.explanation = explanation
        self.revealMode = revealMode
    }
}
