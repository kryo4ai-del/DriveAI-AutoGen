// File: Views/ExamResultsView.swift
import SwiftUI

struct ExamResultsView: View {
    @EnvironmentObject private var viewModel: ExamPrepViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Exam Completed")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text("Your Score")
                    .font(.headline)
                Text("\(viewModel.score)/\(viewModel.questions.count)")
                    .font(.system(size: 48, weight: .bold))
            }

            if viewModel.hasPassed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                Text("Congratulations! You passed.")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                Text("You didn't pass this time.")
                    .font(.title2)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Review your answers:")
                    .font(.headline)

                ForEach(viewModel.questions) { question in
                    HStack(alignment: .top) {
                        Image(systemName: viewModel.userAnswers[question.id] == question.correctAnswerIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewModel.userAnswers[question.id] == question.correctAnswerIndex ? .green : .red)

                        VStack(alignment: .leading) {
                            Text(question.questionText)
                                .font(.subheadline)
                            Text(question.options[question.correctAnswerIndex])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Button("Take Another Exam") {
                viewModel.resetExam()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}