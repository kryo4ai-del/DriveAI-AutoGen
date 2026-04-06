// ViewModels/Performance/ExamResultViewModel.swift

@MainActor
final class ExamResultViewModel: ObservableObject {
    @Published private(set) var exam: ExamAttempt
    @Published private(set) var feedback: ExamFeedback
    
    init(exam: ExamAttempt) {
        self.exam = exam
        self.feedback = ExamFeedback(for: exam)
    }
}
