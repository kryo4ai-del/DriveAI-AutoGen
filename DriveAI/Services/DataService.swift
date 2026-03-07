import Foundation

class DataService {
    func loadQuestions(completion: @escaping ([Question]) -> Void) {
        // Simulating data fetching from DB
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let questions = [
                Question(questionText: "Was ist hier erlaubt?", correctAnswer: "Parken erlaubt", givenAnswer: "Parken verboten", isCorrect: false),
                Question(questionText: "Welche Farbe hat ein Stoppschild?", correctAnswer: "Rot", givenAnswer: "Gelb", isCorrect: false)
            ]
            completion(questions)
        }
    }
}