import SwiftUI

struct SampleValidationView: View {
    @StateObject private var viewModel = SampleValidationViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Run button
                Button(action: { viewModel.runAll() }) {
                    Label("Run All Samples", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // Summary cards
                if viewModel.totalRun > 0 {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Samples Run", value: "\(viewModel.totalRun)",
                                 icon: "checklist", color: .blue)
                        StatCard(title: "Passed", value: "\(viewModel.totalPassed)",
                                 icon: "checkmark.circle.fill",
                                 color: viewModel.totalPassed == viewModel.totalRun ? .green : .orange)
                    }
                }

                // MARK: Questions section
                sectionHeader("Questions", icon: "questionmark.circle.fill", color: .blue,
                              passed: viewModel.passedQuestions, total: viewModel.questionResults.count)

                Text("Reference cases — expected I/O for the question analysis pipeline. Marked as reference; not live-tested against the LLM to avoid API cost.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if viewModel.questionResults.isEmpty {
                    placeholderCard("Tap \"Run All Samples\" to load question reference cases.")
                } else {
                    ForEach(viewModel.questionResults) { result in
                        ValidationResultCard(result: result)
                    }
                }

                // MARK: Traffic Signs section
                sectionHeader("Traffic Signs", icon: "exclamationmark.triangle.fill", color: .orange,
                              passed: viewModel.passedSigns, total: viewModel.signResults.count)

                Text("Live-tested against TrafficSignRecognitionService using programmatic color images.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if viewModel.isRunningSignTests {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Running sign recognition…")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if viewModel.signResults.isEmpty {
                    placeholderCard("Sign tests will run live through the recognition heuristic.")
                } else {
                    ForEach(viewModel.signResults) { result in
                        ValidationResultCard(result: result)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Sample Validation")
    }

    // MARK: - Section header

    private func sectionHeader(_ title: String, icon: String, color: Color, passed: Int, total: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.title3)
                .bold()
            Spacer()
            if total > 0 {
                Text("\(passed)/\(total)")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((passed == total ? Color.green : Color.orange).opacity(0.12))
                    .foregroundColor(passed == total ? .green : .orange)
                    .cornerRadius(6)
            }
        }
    }

    private func placeholderCard(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

// MARK: - Result Card

struct ValidationResultCard: View {
    let result: ValidationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row
            HStack {
                Image(systemName: result.overallPassed ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(result.overallPassed ? .green : .orange)
                Text(result.sample.title)
                    .font(.subheadline)
                    .bold()
                Spacer()
                if !result.isLiveTested {
                    Text("Reference")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.12))
                        .foregroundColor(.secondary)
                        .cornerRadius(4)
                }
            }

            Divider()

            // Input
            fieldRow("Input", value: result.sample.inputDescription)

            // Expected vs Actual
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(result.sample.expectedResult)
                        .font(.caption)
                        .bold()
                    Text(result.sample.expectedCategory)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Actual")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(result.actualResult)
                        .font(.caption)
                        .bold()
                        .foregroundColor(result.resultMatches ? .green : .red)
                    Text(result.actualCategory)
                        .font(.caption2)
                        .foregroundColor(result.categoryMatches ? .primary : .orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Confidence bar
            confidenceRow

            // Explanation
            fieldRow("Explanation", value: result.actualExplanation)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(result.overallPassed ? Color.green.opacity(0.3) : Color.orange.opacity(0.4), lineWidth: 1)
        )
    }

    private var confidenceRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Confidence")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(result.actualConfidence * 100))%")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(result.confidenceOk ? .green : .orange)
                Text("(min \(Int(result.sample.expectedConfidenceMin * 100))%)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(result.confidenceOk ? Color.green : Color.orange)
                        .frame(width: geo.size.width * result.actualConfidence, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func fieldRow(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
