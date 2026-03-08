import SwiftUI

struct AnalysisDebugPanel: View {
    @StateObject private var viewModel = AnalysisDebugPanelViewModel()

    // Optional: inject from QuestionViewModel for live debug
    var confidence: AnswerConfidence?
    var userAnswer: String?
    var correctAnswer: String?
    var evaluationResult: String?

    private let historyService = QuestionHistoryService()

    private var lastHistoryEntry: QuestionHistoryEntry? {
        historyService.fetch().first
    }

    private var topWeakCategories: [WeaknessCategory] {
        historyService.topWeakCategories(limit: 3)
    }

    private var learningStats: LearningStats {
        historyService.calculateLearningStats()
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Confidence section (shown when available)
                if let confidence = confidence {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Answer Confidence")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        HStack {
                            Text("\(confidence.label) (\(confidence.percentage)%)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(confidenceColor(for: confidence.score))
                                    .frame(width: geo.size.width * confidence.score, height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    Divider()
                }

                // Evaluation section
                if userAnswer != nil || correctAnswer != nil || evaluationResult != nil {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Evaluation")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        if let ua = userAnswer {
                            debugRow(label: "User Answer", value: ua)
                        }
                        if let ca = correctAnswer {
                            debugRow(label: "Correct Answer", value: ca)
                        }
                        if let er = evaluationResult {
                            debugRow(label: "Result", value: er)
                        }
                    }
                    Divider()
                }

                // Last history entry
                if let last = lastHistoryEntry {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last History Entry")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        // Image preview
                        if let data = last.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }

                        debugRow(label: "Question", value: String(last.questionText.prefix(60)))
                        debugRow(label: "User Answer", value: last.userAnswer)
                        debugRow(label: "Correct", value: last.correctAnswer)
                        debugRow(label: "Result", value: last.isCorrect ? "Correct" : "Incorrect")
                        if last.confidenceScore > 0 {
                            debugRow(label: "Confidence", value: "\(last.confidenceLabel) (\(Int(last.confidenceScore * 100))%)")
                        }
                    }
                    Divider()
                }

                // Learning statistics preview
                if learningStats.totalQuestions > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Learning Statistics")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        debugRow(label: "Total",    value: "\(learningStats.totalQuestions) questions")
                        debugRow(label: "Accuracy", value: "\(learningStats.accuracyPercentage)%")
                        debugRow(label: "Correct",  value: "\(learningStats.correctAnswers)")
                        debugRow(label: "Incorrect", value: "\(learningStats.incorrectAnswers)")
                        if learningStats.averageConfidence > 0 {
                            debugRow(label: "Avg Confidence", value: "\(learningStats.averageConfidencePercentage)%")
                        }
                    }
                    .padding(.bottom, 8)
                    Divider()
                }

                // Weakness summary
                if !topWeakCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weakness Summary")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        ForEach(topWeakCategories) { cat in
                            debugRow(label: cat.categoryName,
                                     value: "\(cat.accuracyPercentage)% (\(cat.incorrectCount)/\(cat.totalAttempts) wrong)")
                        }
                    }
                    .padding(.bottom, 8)
                    Divider()
                }

                // Debug log list
                Text("Analysis Debug Panel")
                    .font(.title3)
                    .bold()
                    .padding([.horizontal, .top])

                List(viewModel.debugLogs) { log in
                    HStack {
                        Text(log.timestamp, formatter: dateFormatter)
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(log.message)
                            .font(.body)
                            .foregroundColor(log.level == .error ? .red : .black)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Debug Info", displayMode: .inline)
        }
    }

    private func debugRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }

    private func confidenceColor(for score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }
}
