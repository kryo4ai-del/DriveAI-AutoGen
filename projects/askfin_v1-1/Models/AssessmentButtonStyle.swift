struct AssessmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Minimum touch target
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .contentShape(Rectangle()) // Expand hit area
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// Usage
// [FK-019 sanitized] Button(action: { viewModel.submitAnswer(selectedOption) }) {
// [FK-019 sanitized]     Text("Submit Answer")
// [FK-019 sanitized] }
// [FK-019 sanitized] .buttonStyle(AssessmentButtonStyle())