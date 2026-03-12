import SwiftUI

struct TrafficSignStatisticsView: View {
    @StateObject private var viewModel = TrafficSignStatsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.stats.totalSignsReviewed == 0 {
                    emptyState
                } else {
                    summaryCards
                    if viewModel.stats.learningModeAnswers > 0 {
                        accuracySection
                        correctIncorrectChart
                    } else {
                        assistOnlyNote
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Sign Statistics")
        .onAppear { viewModel.load() }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No sign data yet.")
                .font(.headline)
            Text("Analyze traffic signs to see your statistics.")
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
            StatCard(title: "Signs Reviewed",  value: "\(viewModel.stats.totalSignsReviewed)",  icon: "eye.fill",            color: .orange)
            StatCard(title: "Avg Confidence",  value: "\(viewModel.stats.averageConfidencePercentage)%", icon: "waveform.path.ecg", color: .blue)
            StatCard(title: "Correct",         value: "\(viewModel.stats.correctAnswers)",       icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Incorrect",       value: "\(viewModel.stats.incorrectAnswers)",     icon: "xmark.circle.fill",     color: .red)
        }
    }

    // MARK: - Accuracy bar (learning mode only)

    private var accuracySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Learning Mode Accuracy")
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
                Text("\(viewModel.stats.learningModeAnswers) answers")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                chartBar(label: "Correct",
                         count: viewModel.stats.correctAnswers,
                         total: viewModel.stats.learningModeAnswers,
                         color: .green)
                chartBar(label: "Incorrect",
                         count: viewModel.stats.incorrectAnswers,
                         total: viewModel.stats.learningModeAnswers,
                         color: .red)
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

    // MARK: - Assist-only note

    private var assistOnlyNote: some View {
        VStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
            Text("All signs were analyzed in Assist Mode.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Switch to Learning Mode to track correct/incorrect answers.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
