import Foundation
import Combine

// MARK: - SessionType

/// Adaptive strategy for building a training question queue.
///
/// `Equatable` synthesis depends on `TopicArea: Equatable`. `TopicArea` is a
/// plain enum with no associated values so synthesis is automatic.
enum SessionType: Equatable {
    case spacingDue
    case weakestTopics
    case coverageGaps
    /// Custom topics used verbatim as the primary tier. `buildQuestionQueue`
    /// still tops up to `minimumQuestions` if the list is short.
    case custom([TopicArea])
}

enum SessionSetupError: Equatable {
    case emptyQuestionBank
}

// MARK: - ViewModel

@MainActor
final class TrainingSessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var phase: SessionPhase = .brief(previewText: "")
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var questions: [SessionQuestion] = []
    @Published private(set) var results: [SessionResult] = []
    @Published private(set) var optionsRevealed: Bool = false
    @Published private(set) var completedSession: TrainingSession?
    @Published private(set) var sessionError: SessionSetupError?

    // NOT @Published — only needed by AnswerRevealView for one render cycle.
    // Publishing causes two extra layout passes per answer submission.
    private(set) var previousCompetenceLevel: CompetenceLevel = .notStarted
    private(set) var currentCompetenceLevel: CompetenceLevel = .notStarted

    // MARK: - Computed

    var isLastQuestion: Bool {
        !questions.isEmpty && currentIndex == questions.count - 1
    }

    var currentQuestion: SessionQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    /// Uses `results.count` so the bar reaches 1.0 when the final answer lands.
    var sessionProgress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(results.count) / Double(questions.count)
    }

    /// Denominator is `questions.count` — constant throughout the session.
    var progressText: String {
        let correct = results.filter(\.wasCorrect).count
        let topicName = currentQuestion?.topic.displayName ?? ""
        return "\(correct) von \(questions.count) richtig · \(topicName)"
    }

    // MARK: - Dependencies

    private let competenceService: TopicCompetenceService
    private let questionBank: QuestionBankProtocol
    private let haptics: HapticFeedbackProtocol
    let sessionType: SessionType

    // MARK: - Private State

    private var sessionStartDate: Date = .now
    private var isProcessingAnswer = false

    // MARK: - Init

    init(
        competenceService: TopicCompetenceService,
        questionBank: QuestionBankProtocol,
        haptics: HapticFeedbackProtocol,
        sessionType: SessionType
    ) {
        self.competenceService = competenceService
        self.questionBank = questionBank
        self.haptics = haptics
        self.sessionType = sessionType
    }

    // MARK: - Lifecycle

    func startSession() {
        sessionStartDate = Date()
        currentIndex = 0
        results = []
        optionsRevealed = false
        completedSession = nil
        sessionError = nil
        isProcessingAnswer = false
        previousCompetenceLevel = .notStarted
        currentCompetenceLevel = .notStarted

        let topics = resolvedTopics()
        let config = competenceService.config
        let targetCount = min(
            max(topics.count, config.minimumQuestions),
            config.maximumQuestions
        )
        let queue = buildQuestionQueue(from: topics, targetCount: targetCount)

        guard !queue.isEmpty else {
            sessionError = .emptyQuestionBank
            return
        }

        questions = queue
        phase = .brief(previewText: makePreviewText(for: topics))
    }

    func dismissBrief() {
        guard case .brief = phase else { return }
        withAnimation(.easeInOut(duration: 0.25)) { phase = .question }
    }

    /// Ordering is load-bearing:
    /// 1. Capture previous level before `record()`.
    /// 2. `record()` mutates competences synchronously.
    /// 3. Capture current level after `record()`.
    /// If `record()` becomes async, step 3 must move into the continuation.
    func submitAnswer(direction: SwipeDirection) {
        guard
            let question = currentQuestion,
            case .question = phase,
            !isProcessingAnswer
        else { return }

        isProcessingAnswer = true

        previousCompetenceLevel = competenceService
            .competences[question.topic]?.competenceLevel ?? .notStarted

        let wasCorrect = question.isCorrect(swipeDirection: direction)
        let missDistance = question.missDistance(for: direction)
        let result = SessionResult(
            questionID: UUID(),
            topic: question.topic,
            wasCorrect: wasCorrect,
            selectedDirection: direction,
            answeredAt: Date()
        )

        results.append(result)
        competenceService.record(result: result)

        currentCompetenceLevel = competenceService
            .competences[question.topic]?.competenceLevel ?? .notStarted

        haptics.trigger(wasCorrect ? .success : .error)

        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .reveal(wasCorrect: wasCorrect, missDistance: missDistance)
        }
    }

    /// Only valid during `.reveal` — calls in other phases are silently ignored.
    func advance() {
        guard case .reveal = phase, !questions.isEmpty else { return }
        isProcessingAnswer = false
        let nextIndex = currentIndex + 1
        if nextIndex < questions.count {
            currentIndex = nextIndex
            optionsRevealed = false
            withAnimation(.easeInOut(duration: 0.25)) { phase = .question }
        } else {
            completedSession = TrainingSession(
                sessionType: sessionType,
                results: results,
                startedAt: sessionStartDate,
                completedAt: Date()
            )
            withAnimation(.easeInOut(duration: 0.3)) { phase = .summary }
        }
    }

    // MARK: - Private: Adaptive Queue

    private func resolvedTopics() -> [TopicArea] {
        switch sessionType {
        case .custom(let topics): return topics
        case .spacingDue:
            return prioritisedTopics(tiers: [
                competenceService.dueTopics(),
                competenceService.weakestTopics(),
                competenceService.leastCoveredTopics()
            ])
        case .weakestTopics:
            return prioritisedTopics(tiers: [
                competenceService.weakestTopics(),
                competenceService.leastCoveredTopics(),
                competenceService.dueTopics()
            ])
        case .coverageGaps:
            return prioritisedTopics(tiers: [
                competenceService.leastCoveredTopics(),
                competenceService.weakestTopics(),
                competenceService.dueTopics()
            ])
        }
    }

    private func prioritisedTopics(tiers: [[TopicArea]]) -> [TopicArea] {
        var seen = Set<TopicArea>()
        var ordered: [TopicArea] = []
        for tier in tiers + [TopicArea.allCases] {
            for topic in tier where seen.insert(topic).inserted {
                ordered.append(topic)
            }
        }
        return ordered
    }

    private func buildQuestionQueue(from topics: [TopicArea], targetCount: Int) -> [SessionQuestion] {
        var queue: [SessionQuestion] = []
        // TODO: Replace with question.id once SessionQuestion is Identifiable.
        var seenTexts = Set<String>()
        var coveredTopics = Set<TopicArea>()

        @discardableResult
        func appendIfUnique(_ q: SessionQuestion) -> Bool {
            guard seenTexts.insert(q.text).inserted else { return false }
            queue.append(q)
            return true
        }

        for topic in topics {
            guard queue.count < targetCount else { break }
            if let q = questionBank.randomQuestion(
                for: topic,
                revealMode: preferredRevealMode(for: topic)
            ) {
                if appendIfUnique(q) { coveredTopics.insert(topic) }
            }
        }

        let minimum = competenceService.config.minimumQuestions

        if queue.count < minimum {
            for topic in TopicArea.allCases.shuffled() {
                guard queue.count < minimum else { break }
                guard !coveredTopics.contains(topic) else { continue }
                if let q = questionBank.randomQuestion(for: topic, revealMode: .immediate) {
                    if appendIfUnique(q) { coveredTopics.insert(topic) }
                }
            }
        }

        // Allow repeat topics rather than delivering under minimumQuestions.
        if queue.count < minimum {
            for topic in TopicArea.allCases.shuffled() {
                guard queue.count < minimum else { break }
                if let q = questionBank.randomQuestion(for: topic, revealMode: .immediate) {
                    appendIfUnique(q)
                }
            }
        }

        return queue
    }

    private func preferredRevealMode(for topic: TopicArea) -> RevealMode {
        competenceService.competences[topic]?.competenceLevel == .mastered ? .promptFirst : .immediate
    }

    // LOCALISATION-TODO: "+N weitere" needs NSLocalizedString before adding locales.
    private func makePreviewText(for topics: [TopicArea]) -> String {
        guard !topics.isEmpty else { return "Allgemeines Training" }
        let names = topics.prefix(3).map(\.displayName).joined(separator: ", ")
        let extra = max(0, topics.count - 3)
        return extra > 0 ? "\(names) +\(extra) weitere" : names
    }
}
