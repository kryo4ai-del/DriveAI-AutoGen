// Use semantic SwiftUI font styles that automatically scale
struct ExamReadinessScreen: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 20) {
            // Question text – uses .body which respects Dynamic Type
            Text(viewModel.currentQuestion?.text ?? "")
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Answer buttons – use .callout for touch target compliance
            ForEach(options) { option in
                Button(action: {}) {
                    Text(option)
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44) // Min touch target
                }
            }
            
            // Progress info – uses .caption2, still scales
            Text("Question \(currentQuestionIndex + 1) of 10")
                .font(.caption2)
            
            // Timer warning – uses .headline for emphasis
            if timeRemaining < 5 {
                Text("⏱️ \(Int(timeRemaining)) seconds remaining")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, sizeCategory > .large ? 16 : 20)
    }
}