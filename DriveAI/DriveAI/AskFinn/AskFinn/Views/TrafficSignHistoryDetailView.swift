import SwiftUI
import UIKit

struct TrafficSignHistoryDetailView: View {
    let entry: TrafficSignHistoryEntry

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .frame(maxWidth: .infinity)
                }

                // Sign name + category
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        categoryBadge(entry.signCategory)
                        Spacer()
                        Text(dateFormatter.string(from: entry.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(entry.signName)
                        .font(.title2)
                        .bold()
                }

                // Learning mode result
                if entry.wasLearningMode {
                    HStack(spacing: 12) {
                        Image(systemName: entry.userAnswerCorrect == true
                              ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(entry.userAnswerCorrect == true ? .green : .red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.userAnswerCorrect == true ? "Correct" : "Incorrect")
                                .font(.headline)
                                .foregroundColor(entry.userAnswerCorrect == true ? .green : .red)
                            if let selected = entry.userSelectedMeaning {
                                Text("Your answer: \(selected)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Divider()

                // Explanation
                VStack(alignment: .leading, spacing: 6) {
                    Text("Explanation")
                        .font(.headline)
                    Text(entry.explanation)
                        .font(.body)
                }

                // Confidence
                VStack(alignment: .leading, spacing: 6) {
                    Text("Confidence")
                        .font(.headline)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(.systemGray5))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 5)
                                .fill(confidenceColor(entry.confidence))
                                .frame(width: geo.size.width * entry.confidence, height: 10)
                        }
                    }
                    .frame(height: 10)
                    Text("\(entry.confidenceLabel) – \(entry.confidencePercentage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(entry.signName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryBadge(_ category: TrafficSignCategory) -> some View {
        Text(category.rawValue)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor(category).opacity(0.15))
            .foregroundColor(categoryColor(category))
            .cornerRadius(6)
    }

    private func categoryColor(_ category: TrafficSignCategory) -> Color {
        switch category {
        case .prohibitory:   return .red
        case .mandatory:     return .blue
        case .warning:       return .orange
        case .priority:      return .yellow
        case .informational: return .green
        case .unknown:       return .gray
        }
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
