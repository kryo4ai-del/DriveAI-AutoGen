@MainActor
final class LearningGapsViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState = .idle
    @Published var retryAttempt: Int = 0
    
    private let maxRetries = 3
    private var retryTask: Task<Void, Never>?
    
    private let diagnosisUseCase: any DiagnoseLearningGapsUseCase
    private let userId: String
    private let logger: Logger
    
    init(
        diagnosisUseCase: any DiagnoseLearningGapsUseCase,
        userId: String,
        logger: Logger = Logger()
    ) {
        self.diagnosisUseCase = diagnosisUseCase
        self.userId = userId
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    func loadGaps() {
        retryTask?.cancel()
        retryAttempt = 0
        performDiagnosis()
    }
    
    func retry() {
        guard retryAttempt < maxRetries else {
            viewState = .error("Maximale Wiederholungsversuche erreicht. Bitte versuchen Sie es später erneut.")
            return
        }
        
        retryAttempt += 1
        logger.info("Retry attempt \(retryAttempt)/\(maxRetries)")
        
        // Exponential backoff: 1s, 2s, 4s
        let delay: UInt64 = UInt64(pow(2.0, Double(retryAttempt - 1))) * 1_000_000_000
        
        retryTask = Task {
            try? await Task.sleep(nanoseconds: delay)
            await performDiagnosis()
        }
    }
    
    // MARK: - Private Methods
    
    private func performDiagnosis() async {
        viewState = .loading
        
        do {
            let result = try await diagnosisUseCase.execute(userId: userId)
            viewState = .loaded(result.gaps)
            retryAttempt = 0  // Reset on success
            
            if !result.isComplete {
                logger.warn("Partial diagnosis: \(result.failureCount) categories failed")
            }
        } catch {
            let userMessage = mapErrorToUserMessage(error)
            viewState = .error(message: userMessage)
            logger.error("Diagnosis failed: \(error)")
        }
    }
    
    private func mapErrorToUserMessage(_ error: Error) -> String {
        // Map technical errors to user-friendly German messages
        if let localError = error as? DiagnosisError {
            return localError.userMessage
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "Keine Internetverbindung. Bitte versuchen Sie es später erneut."
            case .timedOut:
                return "Die Anfrage hat zu lange gedauert. Bitte versuchen Sie es später erneut."
            default:
                return "Ein Netzwerkfehler ist aufgetreten."
            }
        }
        
        return "Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut."
    }
}

enum DiagnosisError: LocalizedError {
    case completeFailure([CategoryDiagnosisError])
    case repositoryUnavailable
    case invalidUserId
    
    var errorDescription: String? {
        switch self {
        case .completeFailure: return "Diagnose konnte nicht abgeschlossen werden"
        case .repositoryUnavailable: return "Datenbankfehler"
        case .invalidUserId: return "Benutzer-ID ungültig"
        }
    }
    
    var userMessage: String {
        switch self {
        case .completeFailure:
            return "Die Diagnose konnte nicht abgeschlossen werden. Bitte versuchen Sie es später erneut."
        case .repositoryUnavailable:
            return "Die Datenbank ist nicht verfügbar. Bitte versuchen Sie es später erneut."
        case .invalidUserId:
            return "Benutzer nicht gefunden. Bitte melden Sie sich ab und erneut an."
        }
    }
}

enum CategoryDiagnosisError: Error, Equatable {
    case noQuestionsFound(categoryId: String, categoryName: String)
    case fetchFailed(categoryId: String, categoryName: String, reason: String)
}