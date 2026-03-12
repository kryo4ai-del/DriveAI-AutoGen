import SwiftUI

struct FeedbackView: View {
    let feedback: String
    let isCorrect: Bool
    
    var body: some View {
        Text(feedback)
            .font(.subheadline)
            .foregroundColor(isCorrect ? .green : .red) // Color feedback
            .padding()
            .transition(.slide) // Add a transition animation
            .animation(.easeIn, value: feedback) // Animate changes
    }
}