@FocusState private var focusState: FocusField?
enum FocusField { case nextButton }

var body: some View {
    VStack {
        if showFeedback {
            QuestionFeedbackView()
                .transition(.opacity)
        } else {
            VStack {
                Text(question.text)
                    .accessibilityAddTraits(.isHeader)
                
                ForEach(0..<1) { _ in }
            }
            .onAppear {
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