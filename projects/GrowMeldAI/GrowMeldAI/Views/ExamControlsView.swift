// File: Views/ExamControlsView.swift
import SwiftUI

struct ExamControlsView: View {
    @EnvironmentObject private var viewModel: ExamPrepViewModel

    var body: some View {
        HStack {
            if viewModel.currentQuestionIndex > 0 {
                Button("Previous") {
                    viewModel.previousQuestion()
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                Button("Next") {
                    viewModel.nextQuestion()
                }
                .buttonStyle(.borderedProminent)
            } else {
                NavigationLink("Finish Exam") {
                    ExamResultsView()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}