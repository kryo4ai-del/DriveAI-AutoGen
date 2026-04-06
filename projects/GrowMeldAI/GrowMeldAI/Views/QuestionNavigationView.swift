@MainActor
class QuestionNavigationView: View {
    @State private var focusedElement: FocusableElement?
    
    enum FocusableElement: Hashable {
        case questionText
        case answerA, answerB, answerC, answerD
        case nextButton
        case submitButton
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Question at top (focused first)
            Text(question.questionText)
                .accessibilityFocused($focusedElement, equals: .questionText)
                .onAppear {
                    focusedElement = .questionText  // VoiceOver starts here
                }
            
            // Answers in order
            ForEach([0, 1, 2, 3], id: \.self) { idx in
                Button(question.answers[idx]) {
                    selectedAnswer = idx
                }
                .accessibilityFocused($focusedElement, equals: focusElement(for: idx))
            }
            
            // Action buttons last
            Button("Weiter") { /* ... */ }
                .accessibilityFocused($focusedElement, equals: .nextButton)
            
            Button("Einreichen") { /* ... */ }
                .accessibilityFocused($focusedElement, equals: .submitButton)
        }
    }
    
    private func focusElement(for index: Int) -> FocusableElement {
        switch index {
        case 0: return .answerA
        case 1: return .answerB
        case 2: return .answerC
        case 3: return .answerD
        default: return .answerA
        }
    }
}