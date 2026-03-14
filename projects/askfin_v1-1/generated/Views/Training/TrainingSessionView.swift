// Views/Training/TrainingSessionView.swift

struct TrainingSessionView: View {

    @StateObject private var viewModel: TrainingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: TrainingSessionViewModel) {
        // Use the injected ViewModel — never create services internally
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            phaseContent
        }
        .onAppear { viewModel.startSession() }
        .animation(.easeInOut(duration: 0.25), value: viewModel.phase)
    }

    // Explicit exhaustive switch (C-6): compiler enforces all cases
    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {

        case .brief(let previewText):
            SessionBriefView(
                previewText: previewText,
                onStart: viewModel.dismissBrief
            )
            .transition(.opacity)

        case .question:
            QuestionCardView(
                question: currentQuestion,
                progressText: viewModel.progressText,
                onSwipe: viewModel.submitAnswer(direction:)
            )
            .id(viewModel.currentIndex)  // forces SwiftUI to rebuild, not reuse
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))

        case .reveal(let wasCorrect, let missDistance):
            AnswerRevealView(
                question: currentQuestion,
                wasCorrect: wasCorrect,
                missDistance: missDistance,
                currentCompetence: competenceForCurrentTopic,
                onContinue: viewModel.advance
            )
            .transition(.opacity)

        case .summary:
            SessionSummaryView(
                session: buildSession(),
                competenceService: viewModel.competenceService,
                preSessionCompetences: viewModel.preSessionCompetences,
                onDismiss: { dismiss() },
                onTrainWeaknesses: {
                    // Replace current session with weakness-focused one
                    // Navigation handled by parent coordinator in production
                    dismiss()
                }
            )
            .transition(.move(edge: .bottom))
        }
    }

    // MARK: - Helpers

    private var currentQuestion: SessionQuestion {
        // Safe: QuestionCardView/AnswerRevealView only shown when index is valid
        viewModel.questions[viewModel.currentIndex]
    }

    private var competenceForCurrentTopic: TopicCompetence? {
        viewModel.competenceService.competences.first {
            $0.topic == currentQuestion.topic
        }
    }

    private func buildSession() -> TrainingSession {
        TrainingSession(
            sessionType: .adaptive,  // pass actual type from ViewModel if exposed
            results: viewModel.results,
            startedAt: Date(),       // ViewModel should expose startedAt; use placeholder
            completedAt: Date()
        )
    }
}