import SwiftUI
import UIKit

struct QuestionHistoryDetailView: View {
    let entry: QuestionHistoryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Full image preview
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Result header
                HStack {
                    Image(systemName: entry.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(entry.isCorrect ? .green : .red)
                    Text(entry.isCorrect ? "Correct" : "Incorrect")
                        .font(.title2)
                        .bold()
                        .foregroundColor(entry.isCorrect ? .green : .red)
                }
                .padding(.horizontal)

                // Question
                VStack(alignment: .leading, spacing: 4) {
                    Text("Question").font(.caption).foregroundColor(.secondary)
                    Text(entry.questionText).font(.body)
                }
                .padding(.horizontal)

                // Answers
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Answer").font(.caption).foregroundColor(.secondary)
                        Text(entry.userAnswer)
                            .font(.body)
                            .bold()
                            .foregroundColor(entry.isCorrect ? .green : .red)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Correct Answer").font(.caption).foregroundColor(.secondary)
                        Text(entry.correctAnswer)
                            .font(.body)
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)

                // Confidence
                if entry.confidenceScore > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confidence: \(entry.confidenceLabel) (\(Int(entry.confidenceScore * 100))%)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)).frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(confidenceColor(entry.confidenceScore))
                                    .frame(width: geo.size.width * entry.confidenceScore, height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                    }
                }

                // Timestamp
                Text(entry.timestamp.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("History Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
