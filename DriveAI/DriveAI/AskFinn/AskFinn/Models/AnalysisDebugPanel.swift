import SwiftUI
import UIKit

struct AnalysisDebugPanel: View {
    @StateObject private var viewModel = AnalysisDebugPanelViewModel()

    // Optional: inject from QuestionViewModel for live debug
    var confidence: AnswerConfidence?
    var userAnswer: String?
    var correctAnswer: String?
    var evaluationResult: String?

    private let historyService = QuestionHistoryService()
    private let signHistoryService = TrafficSignHistoryService()
    private let categoryDetectionService = QuestionCategoryDetectionService()

    private var lastSignHistoryEntry: TrafficSignHistoryEntry? {
        signHistoryService.fetch().first
    }

    private var lastHistoryEntry: QuestionHistoryEntry? {
        historyService.fetch().first
    }

    private var topWeakCategories: [WeaknessCategory] {
        historyService.topWeakCategories(limit: 3)
    }

    private var learningStats: LearningStats {
        historyService.calculateLearningStats()
    }

    private var signStats: TrafficSignStats {
        signHistoryService.calculateTrafficSignStats()
    }

    private var topWeakSignCategories: [TrafficSignWeaknessCategory] {
        signHistoryService.topWeakSignCategories(limit: 3)
    }

    // Last traffic sign recognition result (injected externally when available)
    var lastSignResult: TrafficSignRecognitionResult?

    var body: some View {
        ScrollView {
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
                        debugRow(label: "Category", value: last.category.rawValue)
                        if last.categoryConfidence > 0 {
                            debugRow(label: "Cat. Confidence", value: "\(Int(last.categoryConfidence * 100))%")
                        }
                        let liveDetection = categoryDetectionService.detectCategory(
                            questionText: last.questionText, answers: [])
                        if !liveDetection.matchedKeywords.isEmpty {
                            debugRow(label: "Keywords", value: liveDetection.matchedKeywords.joined(separator: ", "))
                        }
                    }
                    Divider()
                }

                // Latest saved traffic sign (from history)
                if let sign = lastSignHistoryEntry {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last Sign (History)")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        if let data = sign.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .cornerRadius(6)
                                .padding(.horizontal)
                        }
                        debugRow(label: "Sign",       value: sign.signName)
                        debugRow(label: "Category",   value: sign.signCategory.rawValue)
                        debugRow(label: "Confidence", value: "\(sign.confidenceLabel) (\(sign.confidencePercentage)%)")
                        if sign.wasLearningMode {
                            debugRow(label: "Mode",     value: "Learning")
                            debugRow(label: "Selected", value: sign.userSelectedMeaning ?? "—")
                            debugRow(label: "Result",   value: sign.userAnswerCorrect == true ? "Correct" : "Incorrect")
                        } else {
                            debugRow(label: "Mode",     value: "Assist")
                        }
                    }
                    .padding(.bottom, 8)
                    Divider()
                }

                // Traffic sign recognition preview (live, injected)
                if let sign = lastSignResult {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last Traffic Sign")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        debugRow(label: "Sign",       value: sign.signName)
                        debugRow(label: "Category",   value: sign.signCategory.rawValue)
                        debugRow(label: "Confidence", value: "\(sign.confidenceLabel) (\(sign.confidencePercentage)%)")
                    }
                    .padding(.bottom, 8)
                    Divider()
                }

                // Traffic sign statistics preview
                if signStats.totalSignsReviewed > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sign Statistics")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        debugRow(label: "Reviewed",     value: "\(signStats.totalSignsReviewed) signs")
                        debugRow(label: "Avg Confidence", value: "\(signStats.averageConfidencePercentage)%")
                        if signStats.learningModeAnswers > 0 {
                            debugRow(label: "Accuracy",  value: "\(signStats.accuracyPercentage)%")
                            debugRow(label: "Correct",   value: "\(signStats.correctAnswers)")
                            debugRow(label: "Incorrect", value: "\(signStats.incorrectAnswers)")
                        }
                    }
                    .padding(.bottom, 8)
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

                // Sign weakness summary
                if !topWeakSignCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sign Weakness Summary")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        ForEach(topWeakSignCategories) { cat in
                            debugRow(label: cat.categoryName,
                                     value: "\(cat.accuracyPercentage)% (\(cat.incorrectCount)/\(cat.totalAttempts) wrong)")
                        }
                    }
                    .padding(.bottom, 8)
                    Divider()
                }

                // Sample Validation shortcut
                NavigationLink(destination: SampleValidationView()) {
                    Label("Open Sample Validation", systemImage: "checklist")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.blue.opacity(0.09))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding([.horizontal, .top], 12)

                // Debug log list
                Text("Debug Logs")
                    .font(.title3)
                    .bold()
                    .padding([.horizontal, .top])

                if viewModel.debugLogs.isEmpty {
                    Text("No logs yet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    ForEach(viewModel.debugLogs) { log in
                        HStack(alignment: .top) {
                            Text(log.timestamp, formatter: dateFormatter)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text(log.message)
                                .font(.body)
                                .foregroundColor(log.level == .error ? .red : .primary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Debug Info")
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
