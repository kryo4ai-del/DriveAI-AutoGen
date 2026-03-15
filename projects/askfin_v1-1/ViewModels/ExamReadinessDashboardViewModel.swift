// MARK: - Features/ExamReadiness/ViewModels/ExamReadinessDashboardViewModel.swift

import SwiftUI

@MainActor
final class ExamReadinessDashboardViewModel: ObservableObject {
    @Published var snapshot: ExamReadinessSnapshot?
    @Published var recommendations: [StudyRecommendation] = []
    @Published var isLoading = false
    @Published var error: ReadinessError?
    
    private let cacheCoordinator: CacheCoordinatorService
    private let examDate: Date
    private var activeTask: Task<Void, Never>?
    
    enum ReadinessError: LocalizedError {
        case calculationFailed(String)
        case noData
        case invalidExamDate
        
        var errorDescription: String? {
            switch self {
            case .calculationFailed(let msg):
                return msg
            case .noData:
                return NSLocalizedString("No readiness data available", comment: "")
            case .invalidExamDate:
                return NSLocalizedString("Exam date is in the past", comment: "")
            }
        }
    }
    
    init(
        cacheCoordinator: CacheCoordinatorService,
        examDate: Date
    ) {
        self.cacheCoordinator = cacheCoordinator
        self.examDate = examDate
    }
    
    /// ✅ Thread-safe load with race condition prevention
    func loadReadiness() async {
        // Cancel any in-flight request
        activeTask?.cancel()
        
        isLoading = true
        error = nil
        
        activeTask = Task {
            do {
                // Validate exam date
                guard examDate > Date() else {
                    throw ReadinessError.invalidExamDate
                }
                
                let (snapshot, recs) = try await cacheCoordinator.loadCompleteReadinessPipeline(
                    examDate: examDate
                )
                
                // ✅ Check if cancelled before updating
                guard !Task.isCancelled else { return }
                
                self.snapshot = snapshot
                self.recommendations = recs
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                
                if let readinessError = error as? ReadinessError {
                    self.error = readinessError
                } else {
                    self.error = .calculationFailed(error.localizedDescription)
                }
                self.isLoading = false
            }
        }
    }
    
    func refresh() async {
        await cacheCoordinator.invalidateCache()
        await loadReadiness()
    }
    
    deinit {
        activeTask?.cancel()
    }
}