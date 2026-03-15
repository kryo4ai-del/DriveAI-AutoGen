struct QuestionOptionButton: View {
    let option: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(option)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color.blue : Color.gray)
        }
        .accessibilityLabel("Answer option")
        .accessibilityValue(option)
        .accessibilityHint("Double-tap to select this answer option")
        .accessibilityAddTraits(.isButton)
    }
}

// Question container
// [FK-019 sanitized] VStack(spacing: 16) {
// [FK-019 sanitized]     Text(viewModel.currentQuestion?.text ?? "")
// [FK-019 sanitized]         .accessibilityLabel("Question")
// [FK-019 sanitized]         .accessibilityValue(viewModel.currentQuestion?.text ?? "")
    
// [FK-019 sanitized]     ForEach(viewModel.currentQuestion?.options ?? []) { option in
// [FK-019 sanitized]         QuestionOptionButton(option: option, isSelected: false) {
// [FK-019 sanitized]             viewModel.submitAnswer(option)
        }
    }
}
// [FK-019 sanitized] .accessibilityElement(children: .contain)