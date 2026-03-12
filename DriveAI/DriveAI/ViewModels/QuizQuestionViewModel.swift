import Combine

class QuizQuestionViewModel: ObservableObject {
    var question: QuestionModel

    init(question: QuestionModel) {
        self.question = question
    }
}