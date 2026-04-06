struct AnswerOption: Identifiable, Codable, Hashable {
    let id: String
    let text: String
}

// In QuestionScreen:
ForEach(question.answers) { answer in
    Button(action: { submitAnswer(answer) }) {
        Text(answer.text)  // ❌ No accessibility label
    }
}