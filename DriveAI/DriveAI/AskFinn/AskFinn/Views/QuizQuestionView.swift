import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    var onAnswerSelected: (Int) -> Void

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text(question.question)
                .font(.headline)
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    selectedIndex = index
                    onAnswerSelected(index)
                }) {
                    Text(question.options[index])
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .foregroundColor(.primary)
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
    }
}
