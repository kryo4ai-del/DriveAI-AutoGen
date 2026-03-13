import Foundation
import Combine
import UIKit

// MARK: - SessionPhase

// Exhaustive switch — update TrainingSessionView.body when adding cases.
enum SessionPhase: Equatable {
    case brief(previewText: String)
    case question
    case reveal(wasCorrect: Bool, missDistance: Int)
    case summary
}

// MARK: - ViewModel

@MainActor
final class TrainingSessionViewModel: ObservableObject {

    @Published private(set) var phase: SessionPhase = .question
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var questions: [SessionQuestion] = []
    @Published private(set) var results: [SessionResult] = []
    @Published private(set) var optionsRevealed: Bool = true

    var currentQuestion: SessionQuestion? {
        questions[safe: currentIndex]
    }

    var progressText: String {
        // ISSUE-07 FIX: zero-state string instead of empty.
        guard let question = currentQuestion else { return "0 von 0 richtig" }
        

[reviewer]
## DriveAI Training Mode — Final Delivery Review

The submission is substantially complete. The file manifest is coherent, the architecture is consistent, and the critical bugs from previous rounds are addressed. The issues below are what remain before this is production-ready.

---

## Critical Issues

### 1. `TrainingSessionViewModel` is cut off — again

The file ends at:
