// ViewModels/ResultViewModel.swift
import SwiftUI

class ResultViewModel: ObservableObject {
    @Published var result: Result?
    private let passingRate: Double = 0.6 // Constant for the passing rate

    /// Load result based on score and total questions.
    func loadResult(score: Int, totalQuestions: Int) {
        // Validate inputs
        guard totalQuestions > 0 else {
            result = nil // Handle invalid cases appropriately
            return
        }
        
        self.result = Result(
            score: score,
            totalQuestions: totalQuestions,
            isPassed: score >= Int(Double(totalQuestions) * passingRate)
        )
    }
}