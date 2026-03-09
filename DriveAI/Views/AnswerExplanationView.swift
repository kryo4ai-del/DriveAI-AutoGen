import SwiftUI

struct AnswerExplanationView: View {
    @ObservedObject var viewModel: AnswerExplanationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Result header
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                    Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(viewModel.isCorrect ? .green : .red)
                }
                .padding(.top, 4)

                // Category badge
                if viewModel.detectedCategory != .general || viewModel.categoryConfidence > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(viewModel.detectedCategory.rawValue)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                        if viewModel.categoryConfidence > 0 {
                            Text("\(Int(viewModel.categoryConfidence * 100))%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .cornerRadius(8)
                }

                // Explanation card
                if !viewModel.explanation.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explanation")
                            .font(.headline)
                        Text(viewModel.explanation)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Confidence card
                if viewModel.confidenceScore > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confidence")
                            .font(.headline)
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
                        Text("\(viewModel.confidenceLabel) – \(Int(viewModel.confidenceScore * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Answer Explanation")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var confidenceColor: Color {
        switch viewModel.confidenceScore {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
