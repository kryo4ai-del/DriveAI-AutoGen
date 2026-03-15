import Foundation
import SwiftUI
struct AssessmentProgressView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let timeRemaining: TimeInterval
    
    var progressPercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestion) / Double(totalQuestions)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar with announcement
            ProgressView(value: progressPercentage)
                .accessibilityLabel("Question Progress")
                .accessibilityValue(
                    "Question \(currentQuestion) of \(totalQuestions)"
                )
            
            // Timer with time announcement
            HStack {
                Image(systemName: "clock.fill")
                    .accessibilityHidden(true)
                
                Text(formatTime(timeRemaining))
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue("\(Int(timeRemaining)) seconds")
                    .accessibilityAddTraits(
                        timeRemaining < 5 ? .startsMediaSession : []
                    )
            }
            .foregroundColor(timeRemaining < 5 ? .red : .primary)
        }
        .accessibilityElement(children: .combine)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        String(format: "%02d:%02d", 
            Int(seconds) / 60, 
            Int(seconds) % 60
        )
    }
}