// App/DriveAIApp.swift
import SwiftUI

@main
struct DriveAIApp: App {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var appState: AppState
    
    init() {
        // Initialize services (singleton pattern for data layer only)
        let dataService = LocalDataService.shared
        let preferencesService = UserPreferencesService.shared
        let analyticsService = AnalyticsService.shared
        
        // Create coordinator
        let coordinator = AppCoordinator(
            dataService: dataService,
            preferencesService: preferencesService
        )
        _coordinator = StateObject(wrappedValue: coordinator)
        
        // Create app state
        let appState = AppState(
            preferencesService: preferencesService,
            coordinator: coordinator
        )
        _appState = StateObject(wrappedValue: appState)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Root navigation
                NavigationStack(path: $coordinator.navigationPath) {
                    RootView()
                        .navigationDestination(for: AppCoordinator.Route.self) { route in
                            coordinator.destination(for: route)
                        }
                }
                
                // Global UI layer (alerts, modals if needed)
                if let alert = appState.currentAlert {
                    alertView(for: alert)
                }
            }
            .environmentObject(coordinator)
            .environmentObject(appState)
            .preferredColorScheme(nil) // Respect system dark mode
        }
    }
    
    @ViewBuilder
    private func alertView(for alert: AppAlert) -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(alert.title)
                    .font(.headline)
                
                Text(alert.message)
                    .font(.body)
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        appState.currentAlert = nil
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(alert.actionTitle) {
                        alert.action()
                        appState.currentAlert = nil
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding()
        }
    }
}

// Root view that handles conditional logic
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        if appState.hasCompletedOnboarding {
            DashboardView()
        } else {
            OnboardingView()
        }
    }
}

// ---

@ViewBuilder
private func contentForState() -> some View {
    switch viewModel.state {
    case .idle, .loading: { ... }
    case .presenting  // ❌ Missing implementation

// ---

@ViewBuilder
private func contentForState() -> some View {
    switch viewModel.state {
    case .idle, .loading:
        loadingState()
        
    case .presenting(let question, let selectedAnswer):
        presentingState(question: question, selectedAnswer: selectedAnswer)
        
    case .submitted(let question, let selected, let isCorrect, let explanation):
        submittedState(question: question, selected: selected, isCorrect: isCorrect, explanation: explanation)
        
    case .error(let message):
        errorState(message: message)
    }
}

private func presentingState(question: Question, selectedAnswer: String?) -> some View {
    VStack(spacing: 16) {
        QuestionTextView(text: question.text)
        
        VStack(spacing: 12) {
            ForEach(question.answers, id: \.id) { answer in
                AnswerOptionView(
                    answer: answer,
                    isSelected: selectedAnswer == answer.id,
                    onSelect: { viewModel.selectAnswer(answer.id) }
                )
            }
        }
        
        Button(action: { Task { await viewModel.submitAnswer() } }) {
            Text("Antwort absenden")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedAnswer == nil)
    }
}

// ---

private weak var coordinator: AppCoordinator?
// ...
coordinator?.navigate(to: .results(result))  // ❌ Could be nil

// ---

private var sessionTimer: Timer?

private func startSessionTimer() {
    sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.sessionTime += 1  // ❌ Retains self
    }
}

deinit {
    sessionTimer?.invalidate()  // ✅ Good, but could fail if called early
}

// ---

private var sessionTimer: AnyCancellable?

private func startSessionTimer() {
    sessionTimer = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
            self?.sessionTime += 1
        }
}

// ---

// ❌ No error handling
.onAppear {
    Task {
        await viewModel.loadQuestions()  // What if this fails?
    }
}

// ---

.onAppear {
    Task {
        do {
            await viewModel.loadQuestions()
        } catch {
            appState.showAlert(
                title: "Fehler",
                message: error.localizedDescription,
                actionTitle: "Erneut versuchen",
                action: { /* retry logic */ }
            )
        }
    }
}

// ---

@StateObject private var coordinator: AppCoordinator  // ❌ Should be singleton
@StateObject private var appState: AppState          // ❌ Extra instance

// ---

// ❌ Missing accessibility
Button(action: { Task { await viewModel.submitAnswer() } }) {
    Text("Antwort absenden")
}

// ✅ Fix:
Button(action: { Task { await viewModel.submitAnswer() } }) {
    Text("Antwort absenden")
}
.accessibilityLabel("Ausgewählte Antwort absenden")
.accessibilityHint("Aktivieren Sie diese Schaltfläche, um Ihre Antwort zu überprüfen")

// ---

var passed: Bool {
    accuracy >= 0.75  // ❌ Hardcoded
}

// ---

private static let passingThreshold: Double = 0.75

var passed: Bool {
    accuracy >= Self.passingThreshold
}

// ---

@ViewBuilder
private func contentForState() -> some View {
    switch viewModel.state {
    case .idle, .loading:
        loadingState()
    
    case .presenting  // ❌ INCOMPLETE — missing implementation

// ---

@ViewBuilder
private func contentForState() -> some View {
    switch viewModel.state {
    case .idle, .loading:
        ProgressView()
            .frame(maxHeight: .infinity, alignment: .center)
    
    case .presenting(let question, let selectedAnswer):
        questionPresentingView(question, selectedAnswer)
    
    case .submitted(let q, let selected, let correct, let expl):
        feedbackView(q, selected, correct, expl)
    
    case .error(let msg):
        errorView(msg)
    }
}

@ViewBuilder
private func questionPresentingView(_ question: Question, _ selected: String?) -> some View {
    VStack(spacing: 16) {
        Text(question.text)
            .font(.body)
            .lineLimit(nil)
        
        VStack(spacing: 8) {
            ForEach(question.answers, id: \.id) { answer in
                AnswerButton(
                    answer: answer,
                    isSelected: selected == answer.id,
                    onTap: { viewModel.selectAnswer(answer.id) }
                )
            }
        }
        
        Button("Antwort absenden") {
            Task { await viewModel.submitAnswer() }
        }
        .buttonStyle(.borderedProminent)
        .disabled(selected == nil)
    }
}

// ---

// QuestionViewModel tries to reference this:
case .presenting(question: Question, ...)  // ❌ Type doesn't exist

// ---

init(
    questionService: QuestionService,     // ❌ Never defined
    analyticsService: AnalyticsService,   // ❌ Never defined
    coordinator: AppCoordinator
)

// ---

let dataService = LocalDataService.shared

// ---

private weak var coordinator: AppCoordinator?  // ❌ Can be nil without warning

// Later:
coordinator?.navigate(to: .results)  // If coordinator is deallocated, silently fails

// ---

// In DriveAIApp
.environmentObject(coordinator)

// In QuestionViewModel
@EnvironmentObject var coordinator: AppCoordinator

// Now it crashes visibly if missing, rather than silently failing
func finishSession() {
    let result = QuizResult(...)
    coordinator.navigate(to: .examResults(ExamResult(quizResult: result)))
    // If coordinator is missing, gets @EnvironmentObject error at compile time
}

// ---

private var sessionTimer: Timer?

private func startSessionTimer() {
    sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.sessionTime += 1
    }
}

// ---

private var sessionTimer: AnyCancellable?

private func startSessionTimer() {
    sessionTimer = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
            self?.sessionTime += 1
        }
}

// Timer automatically cancels when AnyCancellable is deallocated
deinit {
    sessionTimer?.cancel()  // Explicit cleanup (Combine handles this automatically)
}

// ---

.onAppear {
    Task {
        await viewModel.loadQuestions()  // What if this throws?
    }
}

// ---

.onAppear {
    Task {
        do {
            await viewModel.loadQuestions()
        } catch {
            // Manually update state to error
            viewModel.setState(.error(error.localizedDescription))
        }
    }
}

// ---

func loadQuestions(from category: Category? = nil) async {
    state = .loading
    do {
        questions = try await questionService.fetchQuestions(category: category)
        if questions.isEmpty {
            state = .error("Keine Fragen verfügbar")
            return
        }
        await presentNextQuestion()
    } catch {
        state = .error(error.localizedDescription)  // ✅ Error state is set
    }
}

// ---

func loadQuestions(from category: Category? = nil) async {
    state = .loading
    do {
        questions = try await questionService.fetchQuestions(...)  // Long operation
        // If user pops view during this, another instance calls loadQuestions
        // Both write to `questions` at the same time
        currentIndex = 0
        await presentNextQuestion()
    }
}

// ---

private var loadTask: Task<Void, Never>?

func loadQuestions(from category: Category? = nil) async {
    // Cancel any in-flight load
    loadTask?.cancel()
    
    loadTask = Task {
        state = .loading
        do {
            guard !Task.isCancelled else { return }
            
            questions = try await questionService.fetchQuestions(category: category)
            
            guard !Task.isCancelled else { return }
            
            currentIndex = 0
            await presentNextQuestion()
        } catch is CancellationError {
            // Expected when user navigates away
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

deinit {
    loadTask?.cancel()
}

// ---

ForEach(question.answers, id: \.id) { answer in  // ❌ If question.answers is empty, doesn't crash but no UI shown
    AnswerButton(...)
}

// ---

let examResult = ExamResult(quizResult: result)

// ---

var accuracy: Double {
    Double(correctAnswers) / Double(totalQuestions)  // ❌ 0/0 = NaN
}

// ---

var accuracy: Double {
    guard totalQuestions > 0 else { return 0.0 }
    return Double(correctAnswers) / Double(totalQuestions)
}

var passed: Bool {
    totalQuestions > 0 && accuracy >= 0.75
}

// ---

init() {
    let dataService = LocalDataService.shared
    let preferencesService = UserPreferencesService.shared
    
    let coordinator = AppCoordinator(...)
    _coordinator = StateObject(wrappedValue: coordinator)
    
    let appState = AppState(
        preferencesService: preferencesService,
        coordinator: coordinator  // ❌ Coordinator not fully initialized yet
    )
    _appState = StateObject(wrappedValue: appState)
}