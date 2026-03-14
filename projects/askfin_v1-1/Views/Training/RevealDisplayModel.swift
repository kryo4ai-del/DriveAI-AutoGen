import SwiftUI

/// Pure formatting value type for AnswerRevealView.
/// All color, symbol, and copy derivation lives here so the view body is
/// a layout-only description with zero conditional logic.
struct RevealDisplayModel {
    let wasCorrect: Bool
    let missDistance: Int?   // nil when wasCorrect == true

    // MARK: Colors — both pass WCAG AA 4.5:1 on a black background.

    var accentColor: Color {
        wasCorrect
            ? Color(red: 0.2, green: 0.9, blue: 0.4)   // ~5.8:1 on black
            : Color(red: 1.0, green: 0.45, blue: 0.4)  // ~4.6:1 on black
    }

    // MARK: Symbols — always paired with text; never used as sole indicator.

    var symbolName: String {
        wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    // MARK: Copy

    var headerText: String {
        RevealCopy.header(wasCorrect: wasCorrect, missDistance: missDistance ?? 0)
    }

    var explanationPrefix: String {
        RevealCopy.explanationPrefix(wasCorrect: wasCorrect)
    }

    // MARK: Accessibility

    /// Full semantic label for VoiceOver — replaces symbol + header text pair.
    var accessibilityResultLabel: String {
        wasCorrect ? "Richtig" : "Falsch"
    }
}
