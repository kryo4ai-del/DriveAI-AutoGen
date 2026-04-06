@FocusState private var focusState: FocusField?
enum FocusField { case nextButton }

var body: some View {
    VStack {
        if showFeedback {
            QuestionFeedbackView(...)
                .transition(.opacity)
        } else {
            // When feedback disappears, next question is visible
            VStack {
                Text(question.text)
                    .accessibilityAddTraits(.isHeader)
                
                ForEach(...) { ... }
            }
            .onAppear {
                // Give VoiceOver 0.5s to register new elements
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAccessibility.post(
                        notification: .screenChanged,
                        argument: "Next question ready"
                    )
                }
            }
        }
    }
}