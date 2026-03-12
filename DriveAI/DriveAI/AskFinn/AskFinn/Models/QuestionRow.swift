import SwiftUI

struct QuestionRow: View {
    let question: Question

    var body: some View {
        VStack(alignment: .leading) {
            Text(question.text)
                .font(.headline)
                .accessibilityLabel(question.text)
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
