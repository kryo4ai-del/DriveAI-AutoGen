case summary  // no associated value in spec

// ---

case .summary(session: session)  // associated value added

// ---

case .summary(let session):

// ---

// In ViewModel:
@Published private(set) var completedSession: TrainingSession?

private func transitionToSummary() {
    completedSession = buildCompletedSession()
    withAnimation(.easeInOut(duration: 0.3)) {
        phase = .summary
    }
}

// In View:
case .summary:
    if let session = viewModel.completedSession {
        SessionSummaryView(...)
    }

// ---

SessionSummaryView(
    session: session,
    competenceService: viewModel.competenceService,  // ← private
    ...
)

// ---

// ViewModel:
let competenceService: TopicCompetenceService  // remove private

// ---

let result = SessionResult(questionID: question.id, ...)

// ---

if competenceVisible {
    competenceSignalBar
        .padding(.horizontal, 24)
        .padding(.top, 20)

// ---

startedAt: Date().addingTimeInterval(-Double(results.count) * 12)

// ---

// ViewModel property:
private var sessionStartedAt: Date = Date()

// In startSession():
sessionStartedAt = Date()

// In buildCompletedSession():
startedAt: sessionStartedAt

// ---

TrainingSession(
    sessionType: sessionType,
    results: results,
    startedAt: ...,
    completedAt: Date()
)

// ---

private var phaseTag: Int {
    switch viewModel.phase {
    case .brief:    return 0
    case .question: return 1
    case .reveal:   return 2
    case .summary:  return 3
    }
}

// ---

.animation(.spring(...), value: viewModel.phase)

// ---

func advance() {
    let nextIndex = currentIndex + 1
    if nextIndex >= questions.count {
        ...
    } else {
        currentIndex = nextIndex

// ---

func advance() {
    guard case .reveal = phase else { return }
    ...
}

// ---

let competence = competenceService.competences.first { $0.topic == topic }

// ---

let competenceMap = Dictionary(
    uniqueKeysWithValues: competenceService.competences.map { ($0.topic, $0) }
)

// ---

var id: TopicArea { topic }

// ---

init(factory: @escaping () -> TrainingSessionViewModel) {
    _viewModel = StateObject(wrappedValue: factory())
}

// ---

InMemoryPersistenceStore()
MockQuestionBank()
SystemHapticFeedback()

// ---

case summary  // no associated value

// ---

phase = .summary(session: session)

// ---

case .summary(let session):

// ---

// Current — breaks if summary has no associated value:
case .summary:  return 3

// After fix — no change needed here, but completedSession must be non-nil guarded in the View

// ---

// ViewModel — expose only what the View layer needs:
var competenceServiceForSummary: TopicCompetenceService { competenceService }

// ---

// Add to SessionQuestion:
let id: UUID  // or String if question catalog uses string keys

// Or if question text is treated as the stable key (fragile but functional for MVP):
let result = SessionResult(
    questionID: question.text.hashValue.description,
    ...
)

// ---

if competenceVisible {
    competenceSignalBar
        .padding(.horizontal, 24)
        .padding(.top, 20)

// ---

startedAt: Date().addingTimeInterval(-Double(results.count) * 12)

// ---

func advance() {
    let nextIndex = currentIndex + 1

    if nextIndex >= questions.count {
        let session = buildCompletedSession()
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .summary(session: session)
        }
    } else {
        currentIndex = nextIndex          // ← written here
        withAnimation(...) {
            phase = .question
            optionsRevealed = false
        }
    }
}

// ---

func advance() {
    guard case .reveal = phase else { return }  // double-tap guard

    let nextIndex = currentIndex + 1

    if nextIndex >= questions.count {
        let session = buildCompletedSession()
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .summary  // after SessionPhase fix
        }
    } else {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            currentIndex = nextIndex      // moved inside animation block
            phase = .question
            optionsRevealed = false
        }
    }
}

// ---

case .reveal(let wasCorrect, let missDistance):
    if let question = viewModel.currentQuestion {
        AnswerRevealView(
            question: question,
            ...
            onContinue: { viewModel.advance() }
        )
    }

// ---

// ViewModel:
@Published private(set) var revealedQuestion: SessionQuestion?

func submitAnswer(direction: SwipeDirection) {
    guard let question = currentQuestion else { return }
    revealedQuestion = question   // capture before index changes
    ...
    phase = .reveal(wasCorrect: wasCorrect, missDistance: missDistance)
}

// View:
case .reveal(let wasCorrect, let missDistance):
    if let question = viewModel.revealedQuestion {
        AnswerRevealView(question: question, ...)
    }

// ---

func startSession() {
    questions = buildAdaptiveQueue()
    currentIndex = 0
    results = []
    guard !questions.isEmpty else { return }  // ← silently stays on .brief phase
    phase = .question
}

// ---

guard !questions.isEmpty else {
    phase = .error("Keine Fragen verfügbar. Bitte App neu starten.")
    return
}

// ---

competenceService.record(result: result)

// ---

let preview = competenceService.nextSessionPreview(for: sessionType)

// ---

// Either:
let preview = competenceService.nextSessionPreview()

// Or update the spec — but since spec is authoritative, remove the parameter.

// ---

var coveredTopics: Set<TopicArea> = []
...
if !coveredTopics.contains(topic) {
    if let question = questionBank.randomQuestion(...) {
        queue.append(question)
        coveredTopics.insert(topic)
    }
}

// ---

for topic in allTopics where !coveredTopics.contains(topic) {
    if let question = questionBank.randomQuestion(for: topic, ...) {
        queue.append(question)
        coveredTopics.insert(topic)   // prevents second question from same topic
    }
    if queue.count >= config.minimumQuestions { break }
}

// ---

var progressText: String {
    let correctCount = results.filter(\.wasCorrect).count
    let total = results.count
    let topicName = currentQuestion?.topic.displayName ?? ""
    ...
    return "\(correctCount) von \(total) richtig · \(topicName)"
}

// ---

var progressText: String {
    let correctCount = results.filter(\.wasCorrect).count
    let total = questions.count   // use total questions, not results so far
    let topicName = currentQuestion?.topic.displayName ?? ""
    if topicName.isEmpty {
        return "\(correctCount) von \(total) richtig"
    }
    return "\(correctCount) von \(total) richtig · \(topicName)"
}

// ---

func dismissBrief() {
    startSession()
}

func startSession() {
    questions = buildAdaptiveQueue()
    currentIndex = 0
    results = []   // ← reset
    ...
}

// ---

func startSession() {
    guard questions.isEmpty else { return }  // idempotent
    ...
}

// ---

@State private var explanationExpanded: Bool = false

// ---

@State private var explanationExpanded: Bool

init(question: SessionQuestion, wasCorrect: Bool, missDistance: Int, onContinue: @escaping () -> Void) {
    self.question = question
    self.wasCorrect = wasCorrect
    self.missDistance = missDistance
    self.onContinue = onContinue
    self._explanationExpanded = State(initialValue: !wasCorrect)
}

// ---

.animation(
    .spring(response:

// ---

// Streak indicator
VStack(spacing: 4) {

// ---

private var topicBreakdown: [(topic: TopicArea, correct: Int, total: Int)] {
    let accuracyByTopic = session.accuracyByTopic
    return accuracyByTopic
        .map { (topic: $0.key, correct: $0.value.correct, total: $0.value.total) }

// ---

guard let start = session.startedAt,
      let end = session.completedAt else { ... }

// ---

private var sessionDurationLabel: String {
    let seconds = Int(session.completedAt.timeIntervalSince(session.startedAt))
    let minutes = seconds / 60
    let secs = seconds % 60
    if minutes > 0 {
        return "\(overallTotal) Fragen · \(minutes) Min \(secs) Sek"
    }
    return "\(overallTotal) Fragen · \(secs) Sek"
}

// ---

let level = CompetenceLevel.from(
    weightedAccuracy: question.topic == question.topic
        ? 0.0
        : 0.0,
    totalAnswers: 0
)

// ---

func submitAnswer(direction: SwipeDirection) {
    guard case .question = phase,
          let question = currentQuestion else { return }

// ---

// Current code (correct — guard is before revealedQuestion assignment):
guard case .question = phase,
      let question = currentQuestion else { return }
revealedQuestion = question

// ---

.animation(.spring(response: 0.4, dampingFraction: 0.82), value: viewModel.phase)

// ---

private var competenceFillFraction: Double {
    switch missDistance {
    case 0:  return min(1.0, 0.75)
    case 1:  return 0.45
    default: return 0.20
    }
}

// ---

func startSession() {
    guard questions.isEmpty else { return }
    ...
}

// ---

.foregroundStyle(accuracyColor(overallAccuracy))

// ---

private func accuracyColor(_ accuracy: Double) -> Color {
    switch accuracy {
    case 0.8...: return .green
    case 0.5..<0.8: return Color(red: 1.0, green: 0.8, blue: 0.0)
    default: return Color(red: 1.0, green: 0.35, blue: 0.35)
    }
}

// ---

.alert(
    "Fehler",
    isPresented: Binding(
        get: { viewModel.errorMessage != nil },
        set: { _ in }           // ← no-op
    ),
    ...
)

// ---

// Option A: expose clearError() on the ViewModel
set: { _ in viewModel.clearError() }

// Option B: make errorMessage a Binding directly
// (requires @Published var errorMessage: String? to be settable)
.alert("Fehler",
       isPresented: Binding(
           get: { viewModel.errorMessage != nil },
           set: { if !$0 { viewModel.clearError() } }
       ), ...)

// ---

func clearError() {
    errorMessage = nil
}

// ---

case .summary:
    if let session = viewModel.completedSession {
        SessionSummaryView(...)
    }
    // else: black screen, no feedback

// ---

case .summary:
    if let session = viewModel.completedSession {
        SessionSummaryView(...)
    } else {
        // Defensive fallback — should not occur in normal flow
        VStack(spacing: 16) {
            Text("Sitzung abgeschlossen")
                .foregroundStyle(.white)
            Button("Fertig") { dismiss() }
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

// ---

competence: viewModel.competenceService.competences.first {
    $0.topic == question.topic
}

// ---

// ViewModel:
func competence(for topic: TopicArea) -> TopicCompetence? {
    competenceService.competences.first { $0.topic == topic }
}

// View:
competence: viewModel.competence(for: question.topic)

// ---

// If SessionPhase gains a new case, the compiler will warn here (exhaustive switch).

// ---

// If SessionPhase gains a new case, this switch will fail to compile —
// update phaseTag and add the corresponding transition logic.

// ---

case .brief:    .zIndex(0)
case .question: .zIndex(1)
case .reveal:   .zIndex(2)
case .summary:  .zIndex(3)

// ---

// zIndex values assume one-directional phase flow: brief → question → reveal → summary.
// If reverse transitions are introduced, these values need revision.

// ---

.accessibilityHidden(true) // progressBar already carries this via label

// ---

// progressLabel: remove .accessibilityHidden
// progressBar: keep .accessibilityElement(children: .ignore) + .accessibilityLabel
//              but also add .accessibilityHidden(true) since progressLabel covers it

// ---

onTrainWeaknesses: {
    // Future: construct a new TrainingSessionView with
    // SessionType.weakFocus and push onto the NavigationStack.
    dismiss()
}

// ---

// MARK: - Public Helpers (add to TrainingSessionViewModel)

/// O(1) competence lookup via the dictionary built in buildAdaptiveQueue.
/// Called from the View layer; kept in the ViewModel to maintain thin views.
func competence(for topic: TopicArea) -> TopicCompetence? {
    competenceService.competences.first { $0.topic == topic }
}

/// Clears the error message. Called by the alert's isPresented setter
/// to prevent the infinite-reappear loop (Review issue 1).
func clearError() {
    errorMessage = nil
}

/// Sets completedSession before transitioning to .summary so the View
/// always finds a non-nil value when it enters the summary phase (Review issue 2).
private func transitionToSummary() {
    completedSession = buildCompletedSession()
    withAnimation(.easeInOut(duration: 0.3)) {
        phase = .summary
    }
}

// Replace the inline call in advance():
// Before: let session = buildCompletedSession()
//         withAnimation { phase = .summary }
// After:  transitionToSummary()