import SwiftUI

// Views/AnswerExplanationView.swift
struct AnswerExplanationView: View {
    @ObservedObject var viewModel: AnswerExplanationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.isCorrect
                 ? NSLocalizedString("Correct", comment: "Correct answer message")
                 : NSLocalizedString("Incorrect", comment: "Incorrect answer message"))
                .font(.largeTitle)
                .foregroundColor(viewModel.isCorrect ? .green : .red)
                .padding(.top)

            if !viewModel.explanation.isEmpty {
                Text(viewModel.explanation)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            // Confidence indicator
            if viewModel.confidenceScore > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Confidence: \(viewModel.confidenceLabel) (\(Int(viewModel.confidenceScore * 100))%)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(confidenceColor)
                                .frame(width: geo.size.width * viewModel.confidenceScore, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.top, 4)
            }
        }
        .navigationTitle(NSLocalizedString("Answer Explanation", comment: "Title for answer explanation view"))
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    private var confidenceColor: Color {
        switch viewModel.confidenceScore {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}

// Views/QuestionView.swift
struct QuestionView: View {
    @StateObject var viewModel = AnswerExplanationViewModel()
    var question: Question

    @State private var isExplanationPresented = false
    @State private var selectedAnswerId: UUID?
    @State private var buttonState: ButtonState = .idle

    var body: some View {
        VStack {
            // Question and answer buttons...
        }
        .sheet(isPresented: $isExplanationPresented) {
            AnswerExplanationView(viewModel: viewModel)
        }
        .padding()
    }
}
