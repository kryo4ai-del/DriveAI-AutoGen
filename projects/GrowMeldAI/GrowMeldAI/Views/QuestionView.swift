// Features/Questions/Views/QuestionView.swift
struct QuestionView: View {
    @StateObject private var viewModel: QuestionViewModel
    @Environment(\.isAccessibilityEnabled) var isA11yEnabled
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Progress
                ProgressView(value: Double(viewModel.progress.current) / Double(viewModel.progress.total))
                    .accessibilityLabel("Question \(viewModel.progress.current) of \(viewModel.progress.total)")
                
                // Streak Badge
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(viewModel.streak)")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .font(.caption)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                
                // Question Content
                switch viewModel.state {
                case .loading:
                    ProgressView()
                    
                case .presenting(let question, let selectedAnswer):
                    QuestionContentView(
                        question: question,
                        selectedAnswer: selectedAnswer,
                        onSelect: { viewModel.selectAnswer($0) }
                    )
                    
                    Button(action: { Task { await viewModel.submitAnswer() } }) {
                        Text("Answer")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedAnswer == nil)
                    
                case .submitted(let question, let selected, let isCorrect, let explanation):
                    FeedbackView(
                        question: question,
                        selectedAnswer: selected,
                        isCorrect: isCorrect,
                        explanation: explanation
                    )
                    
                    Button(action: { Task { await viewModel.nextQuestion() } }) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .error(let message):
                    ErrorView(message: message)
                    
                case .idle:
                    EmptyView()
                }
                
                Spacer()
            }
            .padding()
        }
    }
}