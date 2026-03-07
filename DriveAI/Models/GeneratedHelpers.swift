let passingRate: Double = 0.6

// ---

var detailedFeedback: String {
    isPassed ? "Herzlichen Glückwunsch! Sie haben bestanden." : "Leider haben Sie nicht bestanden. Versuchen Sie es erneut!"
}

// ---

private var resultTitle: String {
       result.isPassed ? "🎉 Sie haben bestanden!" : "❌ Sie haben nicht bestanden"
   }

// ---

if totalQuestions <= 0 {
    result = nil // Or set to a default value
    return
}