import SwiftUI
struct FeedbackOverlayView: View {
    @State var showFeedback = false
    let isCorrect: Bool
    
    var body: some View {
        VStack {
            if showFeedback {
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(isCorrect ? "Korrekt!" : "Nicht ganz richtig")
                }
                .font(.headline)
                .foregroundColor(isCorrect ? .successColor : .errorColor)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showFeedback = true
            }
            if isCorrect {
                HapticFeedback.answerCorrect()
            } else {
                HapticFeedback.answerIncorrect()
            }
        }
    }
}