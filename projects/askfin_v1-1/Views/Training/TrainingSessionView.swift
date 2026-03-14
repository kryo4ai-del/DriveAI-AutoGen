import SwiftUI

// MARK: - TrainingSessionView
//
// Factory-closure init lets the caller control ViewModel construction
// (dependency injection) without requiring @EnvironmentObject threading
// through the navigation stack. The closure is invoked exactly once by
// StateObject — consistent with SwiftUI's wrappedValue init contract.

struct TrainingSessionView: View {

    @StateObject private var viewModel: TrainingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(factory: @escaping () -> TrainingSessionViewModel) {
        _viewModel = StateObject(wrappedValue: factory())
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            phaseContent
                // phaseTag maps SessionPhase cases to Int so SwiftUI can diff
                // animation state without requiring SessionPhase: Equatable.
                // If SessionPhase gains a new case this switch will fail to
                // compile — update phaseTag and add transition logic there too.
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.82),
                    value: phaseTag
                )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                progressLabel
            }
        }
        .alert(
            "Fehler",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                // Issue 1 fix: call clearError() so errorMessage becomes nil,
                // which collapses isPresented to false and breaks the loop.
                set: { if !$0 { viewModel.clearError() } }
            ),
            actions: {
                Button("OK") { viewModel.clearError() }
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }

    // MARK: - Phase Content

    @ViewBuilder
    private var phaseContent: some View {
        // zIndex values assume one-directional phase flow:
        //   brief(0) → question(1) → reveal(2) → summary(3)
        // If reverse transitions are introduced these values need revision.
        switch viewModel.phase {

        case .brief(let previewText):
            SessionBriefView(
                previewText: previewText,
                onDismiss: { viewModel.dismissBrief() }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .zIndex(0)

        case .question:
            questionPhase
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .zIndex(1)

        case .reveal(let wasCorrect, let missDistance):
            // revealedQuestion is captured in submitAnswer() before currentIndex
            // advances — it always holds the question that was actually answered.
            if let question = viewModel.revealedQuestion {
                AnswerRevealView(
                    question: question,
                    wasCorrect: wasCorrect,
                    missDistance: missDistance,
                    selectedDirection: viewModel.results.last?.selectedDirection ?? .right,
                    isLastQuestion: viewModel.isLastQuestion,
                    previousCompetenceLevel: viewModel.previousCompetenceLevel,
                    currentCompetenceLevel: viewModel.currentCompetenceLevel,
                    onContinue: { viewModel.advance() }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(2)
            }

        case .summary:
            summaryPhase
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                .zIndex(3)
        }
    }

    // MARK: - Summary Phase
    //
    // Issue 2 fix: completedSession is set by transitionToSummary() in the
    // ViewModel before phase flips to .summary, making the nil case
    // structurally unreachable in normal flow. The fallback below handles
    // any unforeseen ordering edge without silently showing a black screen.

    @ViewBuilder
    private var summaryPhase: some View {
        if let session = viewModel.completedSession {
            SessionSummaryView(
                session: session,
                competenceService: viewModel.competenceService,
                preSessionLevels: [:],
                onTrainWeaknesses: { dismiss() },
                onDismiss: { dismiss() }
            )
        } else {
            // Defensive fallback — should never be reached.
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)

                Text("Sitzung abgeschlossen")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Button(action: { dismiss() }) {
                    Text("Fertig")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - Question Phase Layout

    private var questionPhase: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            if let question = viewModel.currentQuestion {
                QuestionCardView(
                    question: question,
                    optionsRevealed: viewModel.optionsRevealed,
                    onSwipe: { direction in
                        viewModel.submitAnswer(direction: direction)
                    },
                    onRevealTap: {
                        viewModel.revealOptions()
                    }
                )
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.green)
                    .frame(
                        width: geo.size.width * viewModel.progressFraction,
                        height: 4
                    )
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.9),
                        value: viewModel.progressFraction
                    )
            }
        }
        .frame(height: 4)
        // Issue 6 fix: progressBar is a visual element; the text label in the
        // toolbar is the primary accessible description. Keep the bar accessible
        // as a supplementary value so VoiceOver reads both in correct tree order.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Fortschritt")
        .accessibilityValue("\(Int(viewModel.progressFraction * 100)) Prozent")
    }

    // MARK: - Toolbar: Progress Label

    private var progressLabel: some View {
        Text(viewModel.progressText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.white.opacity(0.7))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            // Issue 6 fix: label is self-describing; keep it visible to VoiceOver
            // as the primary textual progress description.
            .accessibilityLabel(viewModel.progressText)
    }

    // MARK: - Toolbar: Close Button

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.7))
                .frame(width: 32, height: 32)
                .background(
                    Color.white.opacity(0.1),
                    in: Circle()
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sitzung beenden")
    }

    // MARK: - Phase Tag

    private var phaseTag: Int {
        switch viewModel.phase {
        case .brief:    return 0
        case .question: return 1
        case .reveal:   return 2
        case .summary:  return 3
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Training Session — Adaptive") {
    NavigationStack {
        TrainingSessionView {
            TrainingSessionViewModel(
                competenceService: TopicCompetenceService(
                    store: InMemoryPersistenceStore(),
                    config: .standard
                ),
                questionBank: MockQuestionBank(),
                haptics: SystemHapticFeedback(),
                sessionType: .adaptive
            )
        }
    }
}

#Preview("Training Session — Summary Fallback") {
    NavigationStack {
        TrainingSessionView {
            TrainingSessionViewModel(
                competenceService: TopicCompetenceService(
                    store: InMemoryPersistenceStore(),
                    config: .standard
                ),
                questionBank: MockQuestionBank(),
                haptics: SystemHapticFeedback(),
                sessionType: .adaptive
            )
        }
    }
}
#endif
