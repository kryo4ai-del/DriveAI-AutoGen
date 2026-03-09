// ViewModels/AnswerExplanationViewModel.swift
   class AnswerExplanationViewModel: ObservableObject {
       @Published var isCorrect: Bool = false
       @Published var explanation: String = ""

       private var question: Question?

       func loadQuestion(_ question: Question, selectedAnswerId: UUID) {
           self.question = question
           if let question = self.question {
               self.isCorrect = selectedAnswerId == question.correctAnswerId
               self.explanation = question.explanation
           }
       }
   }