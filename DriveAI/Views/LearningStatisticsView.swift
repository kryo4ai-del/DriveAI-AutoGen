import SwiftUI

struct LearningStatisticsView: View {
    @StateObject private var viewModel = LearningStatsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.stats.totalQuestions == 0 {
                    emptyState
                } else {
                    summaryCards
                    accuracySection
                    correctIncorrectChart
                }
            }
            .padding()
        }
        .navigationTitle("Learning Statistics")
        .onAppear { viewModel.load() }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No data yet.")
                .font(.headline)
            Text("Answer questions to see your statistics.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Summary cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total Questions", value: "\(viewModel.stats.totalQuestions)", icon: "questionmark.circle.fill", color: .blue)
            StatCard(title: "Accuracy", value: "\(viewModel.stats.accuracyPercentage)%", icon: "target", color: accuracyColor(viewModel.stats.accuracyRate))
            StatCard(title: "Correct", value: "\(viewModel.stats.correctAnswers)", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Incorrect", value: "\(viewModel.stats.incorrectAnswers)", icon: "xmark.circle.fill", color: .red)
        }
    }

    // MARK: - Accuracy bar

    private var accuracySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overall Accuracy")
                .font(.headline)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accuracyColor(viewModel.stats.accuracyRate))
                        .frame(width: geo.size.width * viewModel.stats.accuracyRate, height: 14)
                }
            }
            .frame(height: 14)

            HStack {
                Text("\(viewModel.stats.accuracyPercentage)% correct")
                    .font(.subheadline)
                    .foregroundColor(accuracyColor(viewModel.stats.accuracyRate))
                Spacer()
                if viewModel.stats.averageConfidence > 0 {
                    Text("Avg confidence: \(viewModel.stats.averageConfidencePercentage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Correct / Incorrect chart

    private var correctIncorrectChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Correct vs Incorrect")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 16) {
                chartBar(
                    label: "Correct",
                    count: viewModel.stats.correctAnswers,
                    total: viewModel.stats.totalQuestions,
                    color: .green
                )
                chartBar(
                    label: "Incorrect",
                    count: viewModel.stats.incorrectAnswers,
                    total: viewModel.stats.totalQuestions,
                    color: .red
                )
            }
            .frame(height: 140)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func chartBar(label: String, count: Int, total: Int, color: Color) -> some View {
        let ratio = total > 0 ? CGFloat(count) / CGFloat(total) : 0
        return VStack(spacing: 4) {
            Text("\(count)")
                .font(.caption)
                .bold()
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(height: geo.size.height * ratio)
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func accuracyColor(_ rate: Double) -> Color {
        switch rate {
        case 0.75...: return .green
        case 0.50...: return .orange
        default:      return .red
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
