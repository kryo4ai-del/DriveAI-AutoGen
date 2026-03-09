import SwiftUI

struct QuestionsListView: View {
    let category: QuestionCategory

    var body: some View {
        VStack {
            Text("Fragen für \(category.name)") // "Questions for [Category Name]" in German
                .font(.largeTitle)
                .padding()
            
            if category.questions.isEmpty {
                Text("Keine Fragen verfügbar.") // "No questions available."
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(category.questions) { question in
                    VStack(alignment: .leading) {
                        Text(question.text)
                            .font(.headline)
                        ForEach(question.options, id: \.self) { option in
                            Button(action: {
                                // Handle answer selection
                            }) {
                                Text(option)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
            Spacer()
        }
        .navigationTitle(category.name)
    }
}