import Foundation

// Used by: AnswerRevealView
// Do not define German copy strings in views — keep them here.
enum RevealCopy {

    static func header(wasCorrect: Bool, missDistance: Int) -> String {
        guard !wasCorrect else { return "Richtig" }
        return missDistance == 1
            ? "Fast richtig — lies genau"
            : "Nicht ganz — hier ist die Regel"
    }

    static func explanationPrefix(wasCorrect: Bool) -> String {
        wasCorrect ? "Darum ist das korrekt:" : "Das ist die Regel:"
    }
}
