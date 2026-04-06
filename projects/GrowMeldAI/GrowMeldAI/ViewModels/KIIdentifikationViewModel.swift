// ViewModels/KIIdentifikationViewModel.swift

import Foundation

@MainActor
final class KIIdentifikationViewModel: ObservableObject {
    @Published var identificationState: IdentificationState = .waiting
    @Published var responseTime: TimeInterval = 0
    @Published var currentQuestion: Question?
    
    private let analyticsService: AnalyticsServiceProtocol
    private let questionService: QuestionServiceProtocol
    private var startTime: Date?
    private var activeTask: Task<Void, Never>?
    
    init(
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
        questionService: QuestionServiceProtocol = QuestionService.shared
    ) {
        self.analyticsService = analyticsService
        self.questionService = questionService
    }
    
    func startIdentificationTimer(for question: Question) {
        // ✅ Cancel any pending operation
        activeTask?.cancel()
        
        currentQuestion = question
        identificationState = .waiting
        startTime = Date()
    }
    
    func submitAnswer(_ answerId: String) {
        guard let startTime else { return }
        
        // ✅ Guard against double-submission
        guard case .waiting = identificationState else {
            print("⚠️ Submission ignored – state is \(identificationState)")
            return
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        // ✅ Clamp to valid range (prevent negative/zero times)
        let validElapsed = max(0.01, elapsed)
        responseTime = validElapsed
        
        // ✅ Cancel previous task if still running
        activeTask?.cancel()
        
        activeTask = Task {
            identificationState = .processing
            
            do {
                let result = try await analyticsService.logKIIdentification(
                    answerId: answerId,
                    responseTime: validElapsed,
                    questionId: currentQuestion?.id ?? ""
                )
                
                // ✅ Verify state hasn't changed
                if case .processing = identificationState {
                    identificationState = .completed(result)
                }
            } catch {
                if case .processing = identificationState {
                    identificationState = .failed(error)
                }
            }
        }
    }
    
    func reset() {
        activeTask?.cancel()
        identificationState = .waiting
        responseTime = 0
        startTime = nil
        currentQuestion = nil
    }
    
    deinit {
        activeTask?.cancel()  // ✅ Cleanup on deallocation
    }
}

// MARK: - State Machine

struct IdentificationResult: Equatable, Codable {
    let isCorrect: Bool
    let responseTime: TimeInterval
    let timestamp: Date
    let nextReviewDate: Date
    let motivationalMessage: String
}