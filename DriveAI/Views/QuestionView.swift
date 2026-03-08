struct QuestionView: View {
    @StateObject private var viewModel = AnalysisStateViewModel()
    private let questionText = "Was ist die Höchstgeschwindigkeit?"
    private let correctAnswer = "50 km/h"
    private let options = ["30 km/h", "50 km/h", "70 km/h"] // Example options for answers

    var body: some View {
        VStack {
            Text(questionText)
                .font(.title)
                .padding()

            // Display buttons for possible answers
            ForEach(options, id: \.self) { option in
                Button(action: {
                    viewModel.analyzeAnswer(for: questionText, userAnswer: option, correctAnswer: correctAnswer)
                }) {
                    Text(option)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                .padding(2)
            }
            
            AnalysisStateView(viewModel: viewModel) // Shows analysis result
                .padding()
        }
        .padding()
    }
}