// Views/Training/TrainingSessionView.swift

import SwiftUI

struct TrainingSessionView: View {

    @StateObject private var viewModel: TrainingSessionViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(viewModel: TrainingSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.phase {
            case .brief(let previewText):
                SessionBriefView(
                    previewText: previewText,
                    onDismiss: { viewModel.dismissBrief() }
                )
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))

            case .question:
                questionLayer

            case .reveal(let wasCorrect, let missDistance):
                if let question = viewModel.currentQuestion {
                    AnswerRevealView(
                        question: question,
                        wasCorrect: wasCorrect,
                        missDistance: missDistance,
                        onContinue: { viewModel.advance() }
                    )
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }

            case .summary:
                SessionSummaryView(
                    results: viewModel.results,
                    onDismiss: { viewModel.startSession() }
                )
                .transition(reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.phase
        )
        .onAppear { viewModel.startSession() }
        .preferredColorScheme(.dark)
    }

    // MARK: - Question Layer

    private var questionLayer: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.

[reviewer]
## DriveAI Training Mode — Code Review

This is the strongest submission in the series. The architecture is coherent, the bugs from previous rounds are resolved, and the view layer is finally present. The issues below are real problems that will affect runtime behavior or maintainability.

---

## Critical Issues

### 1. `TrainingSessionView` is cut off mid-implementation

The file ends at:
