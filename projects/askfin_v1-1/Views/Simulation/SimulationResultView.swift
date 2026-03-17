// SimulationResultView.swift
// Post-simulation result screen.
//
// Pass: "Bestanden" + topic summary + readiness delta
// Fail: "Noch nicht bestanden" + gap analysis ranked by FP impact + CTAs
//
// "Genau dafür ist die Generalprobe da" — failure is expected learning data.
// Post-simulation WHY explanations are the primary learning moment.

import SwiftUI

struct SimulationResultView: View {

    @StateObject private var viewModel: SimulationResultViewModel
    @State private var showingAnswerReview = false
    @State private var selectedGap: SimulationResultViewModel.TopicGap?

    let onRetry: () -> Void
    let onDismiss: () -> Void
    var onTrainWeaknesses: (() -> Void)? = nil

    init(
        result: SimulationResult,
        readinessScore: ReadinessScore?,
        onRetry: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        onTrainWeaknesses: (() -> Void)? = nil
    ) {
        let score = readinessScore ?? ReadinessScore(
            score: result.readinessScoreAtTime,
            milestone: ReadinessMilestone.milestone(for: result.readinessScoreAtTime),
            components: .init(topicCompetence: 0, simulationPerformance: 0, consistency: 0),
            computedAt: Date(),
            delta: result.readinessDelta,
            decayRisk: []
        )
        _viewModel = StateObject(wrappedValue: SimulationResultViewModel(
            result: result,
            readinessScore: score
        ))
        self.onRetry = onRetry
        self.onDismiss = onDismiss
        self.onTrainWeaknesses = onTrainWeaknesses
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultHeader
                Divider().background(Color(.systemGray3)).padding(.horizontal, 20)
                topicBreakdown
                if !viewModel.result.passed {
                    encouragementBanner
                }
                readinessDelta
                actionButtons
            }
            .padding(.vertical, 32)
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showingAnswerReview) {
            AnswerReviewSheet(questionResults: viewModel.questionReviewItems)
        }
    }

    // MARK: - Header

    private var resultHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(viewModel.result.passed ? .green : .orange)

            Text(viewModel.resultHeadline)
                .font(.title.weight(.bold))
                .foregroundColor(.white)

            Text("\(viewModel.result.totalFehlerpunkte) Fehlerpunkte (max. 10)")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(formattedTime)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(viewModel.resultSubheadline)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Topic Breakdown

    private var topicBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.gapAnalysis.isEmpty {
                Text(viewModel.result.passed ? "Themen-Übersicht" : "Was zu tun ist")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                ForEach(viewModel.gapAnalysis) { gap in
                  Button(action: { selectedGap = gap }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(gap.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white)
                            Text(gap.recommendation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(gap.fehlerpunkte) FP")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(gap.fehlerpunkte >= 5 ? .red : .orange)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !viewModel.strongTopics.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gut gemacht")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.green)
                    Text(viewModel.strongTopics.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Encouragement

    private var encouragementBanner: some View {
        Text("Genau dafür ist die Generalprobe da.")
            .font(.footnote.weight(.medium))
            .foregroundColor(.secondary)
            .italic()
            .padding(.horizontal, 20)
    }

    // MARK: - Readiness Delta

    @ViewBuilder
    private var readinessDelta: some View {
        if let delta = viewModel.deltaDescription {
            ReadinessScoreView(score: viewModel.readinessScore, context: .compact)
            Text(delta)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !viewModel.result.passed {
                Button(action: {
                    // Navigate to Training Mode weakness queue
                    if let train = onTrainWeaknesses { train() } else { onDismiss() }
                }) {
                    actionButtonContent("Schwächen trainieren", color: .green)
                }
            }

            Button(action: { showingAnswerReview = true }) {
                actionButtonContent("Alle Antworten ansehen", color: Color(.systemGray4))
            }

            Button(action: onRetry) {
                actionButtonContent("Nochmal simulieren", color: Color(.systemGray4))
            }

            Button(action: onDismiss) {
                Text("Fertig")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func actionButtonContent(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(color == .green ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(12)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = Int(viewModel.result.timeTaken) / 60
        let seconds = Int(viewModel.result.timeTaken) % 60
        return "Zeit: \(String(format: "%d:%02d", minutes, seconds)) von 45:00"
    }
}

// MARK: - Answer Review Sheet

private struct AnswerReviewSheet: View {

    let questionResults: [SimulationResult.QuestionResult]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(questionResults.enumerated()), id: \.element.id) { index, item in
                        answerRow(index: index + 1, item: item)
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Antworten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    private func answerRow(index: Int, item: SimulationResult.QuestionResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Frage \(index)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: item.answerStatus.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(item.answerStatus.isCorrect ? .green : .orange)
                if item.fehlerpunkteAwarded > 0 {
                    Text("\(item.fehlerpunkteAwarded) FP")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.orange)
                }
            }

            Text(item.answerStatus.reviewLabel)
                .font(.caption)
                .foregroundColor(.secondary)

            if !item.answerStatus.isCorrect {
                Text(item.explanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}
