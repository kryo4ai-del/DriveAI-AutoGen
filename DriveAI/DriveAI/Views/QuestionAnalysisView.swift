// Views/QuestionAnalysisView.swift
import SwiftUI

struct QuestionAnalysisView: View {
    @ObservedObject var viewModel: QuestionAnalysisViewModel
    let userAnswer: UserAnswer
    
    var body: some View {
        VStack {
            Text(userAnswer.question.text)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Deine Antwort: \(userAnswer.selectedOption)")
                .font(.subheadline)
                .padding(.top)
            
            if let result = viewModel.analysisResult {
                feedbackView(for: result)
            }
        }
        .onAppear {
            viewModel.analyzeAnswer(userAnswer: userAnswer)
        }
        .padding()
    }
    
    @ViewBuilder
    private func feedbackView(for result: AnalysisResult) -> some View {
        VStack {
            Text(result.feedback)
                .foregroundColor(result.correct ? .green : .red)
                .padding(.top, 10)
                .font(.body)
                .multilineTextAlignment(.center)
            
            if !result.correct {
                Image(systemName: "exclamationmark.triangle") // Example for a warning icon
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
    }
}