// ViewModels/TrainingSessionViewModel.swift

@MainActor
final class TrainingSessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var phase: SessionPhase = .brief(previewText: "")
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var questions: [SessionQuestion] = []
    @Published private(set) var results: [SessionResult] = []
    @Published private(set) var optionsRevealed: Bool = false

    // MARK: - Dependencies

    let competenceService: TopicCompetenceService  // internal for SessionSummaryView
    private let questionBank: QuestionBankProtocol
    private let haptic: HapticFeedbackProtocol
    private let sessionType: SessionType

    // MARK: - Pre-session snapshot (C-5)

    /// Captured before any results are recorded so SessionSummaryView
    /// can compute deltas against the state that existed before this session.
    private(set) var preSessionCompetences: [TopicArea: TopicCompetence] = [:]

    // MARK: - Init

    init(
        competenceService: TopicCompetenceService,
        questionBank: QuestionBankProtocol,
        haptic: HapticFeedbackProtocol,
        sessionType: SessionType
    ) {
        self.competenceService = competenceService
        self.questionBank = questionBank
        self.haptic = haptic
        self.sessionType = sessionType
    }

    // MARK: - Public Interface

    func startSession() {
        // Snapshot competences BEFORE any recording (C-5)
        preSessionCompetences = Dictionary(
            uniqueKeysWithValues: competenceService.competences.map { ($0.topic, $0) }
        )

        let config = competenceService.config
        let orderedTopics = buildAdaptiveTopicOrder()
        questions = buildQueue(from: orderedTopics, config: config)

        // Degrade gracefully when the question bank is empty (C-1)
        guard !questions.isEmpty else {
            phase = .summary
            return
        }

        currentIndex = 0
        results = []
        let preview = makePreviewText()
        phase = .brief(previewText: preview)
    }

    func dismissBrief() {
        guard case .brief = phase else { return }
        phase = .question
    }

    /// Guarded against double-tap and wrong-phase calls (C-2, H-1)
    func submitAnswer(direction: SwipeDirection) {
        guard case .question = phase else { return }
        guard questions.indices.contains(currentIndex) else { return }

        let question = questions[currentIndex]
        let wasCorrect = question.isCorrect(swipeDirection: direction)
        let miss = question.missDistance(for: direction)

        let result = SessionResult(
            questionID: question.id,    // assumes SessionQuestion has an id
            topic: question.topic,
            wasCorrect: wasCorrect,
            selectedDirection: direction,
            answeredAt: Date()
        )
        results.append(result)
        competenceService.record(result: result)  // safe: entire service is @MainActor (C-4)
        haptic.trigger(wasCorrect ? .success : .error)
        phase = .reveal(wasCorrect: wasCorrect, missDistance: miss)
    }

    /// Only advance() mutates currentIndex (H-1 single-responsibility)
    func advance() {
        let next = currentIndex + 1
        if next < questions.count {
            currentIndex = next
            phase = .question
        } else {
            phase = .summary
        }
    }

    // MARK: - Computed Properties

    /// Safe against empty questions array (H-3)
    var progressText: String {
        let correct = results.filter(\.wasCorrect).count
        let topicName = questions.indices.contains(currentIndex)
            ? questions[currentIndex].topic.displayName
            : "–"
        return "\(correct) von \(results.count) richtig · \(topicName)"
    }

    // MARK: - Private Helpers

    private func buildAdaptiveTopicOrder() -> [TopicArea] {
        // Priority: spacing-due → weakest → least covered
        // Use ordered set semantics to avoid duplicates
        var seen = Set<TopicArea>()
        var ordered: [TopicArea] = []

        func append(_ topics: [TopicArea]) {
            for t in topics where seen.insert(t).inserted {
                ordered.append(t)
            }
        }

        switch sessionType {
        case .custom(let topics):
            append(topics)
        case .spacingReview:
            append(competenceService.dueTopics())
        case .weaknessFocus:
            append(competenceService.weakestTopics())
        case .adaptive:
            append(competenceService.dueTopics())
            append(competenceService.weakestTopics())
            append(competenceService.leastCoveredTopics())
        }

        return ordered
    }

    private func buildQueue(
        from topics: [TopicArea],
        config: TrainingConfig
    ) -> [SessionQuestion] {
        var queue: [SessionQuestion] = []
        let mode = resolvedRevealMode()

        for topic in topics {
            // C-1: guard against nil from question bank
            guard let q = questionBank.randomQuestion(for: topic, revealMode: mode) else {
                continue
            }
            queue.append(q)
            if queue.count >= config.maximumQuestions { break }
        }

        // Pad to minimumQuestions by cycling topics if needed
        if queue.count < config.minimumQuestions {
            let remaining = config.minimumQuestions - queue.count
            let fallbackTopics = topics.isEmpty ? Array(TopicArea.allCases) : topics
            for topic in (fallbackTopics * remaining).prefix(remaining) {
                guard let q = questionBank.randomQuestion(for: topic, revealMode: mode) else {
                    continue
                }
                queue.append(q)
            }
        }

        return queue
    }

    private func resolvedRevealMode() -> RevealMode {
        // Hazard questions always use promptFirst
        return .immediate
    }

    private func makePreviewText() -> String {
        let count = questions.count
        let topicNames = Set(questions.map(\.topic.displayName))
        let topicsLabel = topicNames.prefix(2).joined(separator: ", ")
        return "\(count) Fragen · \(topicsLabel)"
    }
}

// Array padding helper — avoids force-unwrap (used in buildQueue)
private func * <T>(array: [T], count: Int) -> [T] {
    guard count > 0, !array.isEmpty else { return [] }
    return (0..<count).flatMap { _ in array }
}