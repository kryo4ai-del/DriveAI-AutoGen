func updateScore(with value: Int) {
       state.score = value
       // Call any other state update methods here if needed.
   }

// ---

let passingRate: Double = 0.6
   private func passingScore() -> Int {
       return Int(Double(state.totalQuestions) * passingRate)
   }

// ---

private func generateFeedbackMessage(for score: Int) -> String {
       switch score {
           case 0..<passingScore():
               return "Leider nicht bestanden. Besuchen Sie die Lernseite für zusätzliche Fragen."
           case passingScore()...state.totalQuestions:
               return "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor."
           default:
               return "Unbekannter Fehler."
       }
   }

// ---

private func calculateScoreBreakdown(correctCount: Int) {
       state.scoreBreakdown = ["Correct": correctCount, "Incorrect": state.totalQuestions - correctCount]
   }