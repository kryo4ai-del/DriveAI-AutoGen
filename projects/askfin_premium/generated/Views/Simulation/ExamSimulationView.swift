// ExamSimulationView.swift
// Full-screen exam simulation: pre-start -> in-progress -> submitted.
//
// Pre-start: shows current readiness + last simulation result.
// In-progress: timer, question progression, Fehlerpunkte counter.
// Submitted: transitions to SimulationResultView.
//
// No feedback during simulation — exam conditions.
// Same swipe gestures as Training Mode (muscle memory transfer).

import SwiftUI

struct ExamSimulationView: View {

    @StateObject private var viewModel: ExamSimulationViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        simulationService: ExamSimulationServiceProtocol,
        readinessService: ReadinessScoreServiceProtocol,
        config: SimulationConfig = .officialExam
    ) {
        _viewModel = StateObject(wrappedValue: ExamSimulationViewModel(
            config: config,
            simulationService: simulationService,
            readinessService: readinessService
        ))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.phase {
            case .preStart:
                preStartContent
            case .inProgress:
                simulationContent
            case .submitted(let result):
                SimulationResultView(
                    result: result,
                    readinessScore: viewModel.currentReadiness,
                    onRetry: { viewModel.startSimulation() },
                    onDismiss: { dismiss() }
                )
            }

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert("Fehler", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onDisappear { viewModel.cancelIfNeeded() }
        .task { await viewModel.loadPreStartData() }
    }

    // MARK: - Pre-Start

    private var preStartContent: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Generalprobe")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                Text("30 Fragen · 45 Minuten")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text("Bestanden ab max. 10 Fehlerpunkte")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider().background(Color(.systemGray3)).padding(.horizontal, 40)

            if let readiness = viewModel.currentReadiness {
                ReadinessScoreView(score: readiness, context: .preStart)
            }

            if let lastResult = viewModel.lastResult {
                lastResultInfo(lastResult)
            }

            Spacer()

            Button(action: { viewModel.startSimulation() }) {
                Text("Simulation starten")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func lastResultInfo(_ result: SimulationResult) -> some View {
        VStack(spacing: 4) {
            Text("Letzte Simulation")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                Text("\(result.totalFehlerpunkte) FP")
                    .font(.headline)
                    .foregroundColor(result.passed ? .green : .orange)
                Text(result.passed ? "bestanden" : "nicht bestanden")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Simulation In-Progress

    private var simulationContent: some View {
        VStack(spacing: 0) {
            simulationHeader
            Divider().background(Color(.systemGray3))
            questionArea
        }
    }

    private var simulationHeader: some View {
        HStack {
            Text("Frage \(viewModel.currentQuestionIndex + 1) / \(viewModel.totalQuestions)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)

            Spacer()

            Text(viewModel.formattedRemainingTime)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundColor(viewModel.remainingTime <= 300 ? .orange : .white)
                .accessibilityLabel(viewModel.accessibilityTimerLabel)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.3))
    }

    private var questionArea: some View {
        VStack(spacing: 24) {
            // Progress bar
            ProgressView(value: viewModel.progressFraction)
                .tint(.green)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            if let question = viewModel.currentQuestion {
                questionCard(question)
            }

            Spacer()

            fehlerpunkteCounter
        }
    }

    private func questionCard(_ question: SessionQuestion) -> some View {
        VStack(spacing: 20) {
            Text(question.questionText)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            // Answer options — tap-based (swipe gestures handled by gesture recognizer)
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                Button(action: { viewModel.recordAnswer(index: index) }) {
                    HStack {
                        Text(optionLabel(index))
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(width: 28)
                        Text(option)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6).opacity(0.4))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Antwort \(optionLabel(index)): \(option)")
            }
        }
    }

    private var fehlerpunkteCounter: some View {
        HStack {
            Spacer()
            // Fehlerpunkte are not shown during realistic simulation
            // to match official exam conditions. Uncomment for practice mode:
            // Text("FP: \(currentFehlerpunkte)")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Loading

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text("Ergebnis wird berechnet...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func optionLabel(_ index: Int) -> String {
        let labels = ["A", "B", "C", "D"]
        return index < labels.count ? labels[index] : "\(index + 1)"
    }
}
