import Foundation
import Combine

class AnalysisStateViewModel: ObservableObject {
    @Published var analysisResult: AnalysisResult?
    @Published var feedbackMessage: String = ""
    @Published var isProcessing: Bool = false

    private let analysisService = AnalysisService() // Reference to the service
    
    func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate processing time safely
            let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
            self.analysisResult = result
            self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
            self.isProcessing = false
            self.analysisService.saveAnalysisResult(result) // Save result after analysis
        }
    }
}