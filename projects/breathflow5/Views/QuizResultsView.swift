// MARK: - Features/Quiz/Views/QuizResultsView.swift
import SwiftUI

struct QuizResultsView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Ergebnis")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Score
                VStack(spacing: 8) {
                    Text("\(viewModel.scorePercentage)%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(viewModel.readinessLevel.color)
                    
                    Text("\(viewModel.score) von \(viewModel.state.questions.count) korrekt")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // Readiness indicator
            ReadinessIndicatorView(
                level: viewModel.readinessLevel,
                weakTopics: viewModel.weakTopics
            )
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.resetQuiz()
                }) {
                    Text("Quiz wiederholen")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Zurück")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding()
    }
}