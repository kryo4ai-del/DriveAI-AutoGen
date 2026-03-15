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
VStack(spacing: 16) {
    Text(viewModel.currentQuestion?.text ?? "")
        .accessibilityLabel("Question")
        .accessibilityValue(viewModel.currentQuestion?.text ?? "")
    
    ForEach(viewModel.currentQuestion?.options ?? []) { option in
        QuestionOptionButton(option: option, isSelected: false) {
            viewModel.submitAnswer(option)
        }
    }
}
.accessibilityElement(children: .contain)