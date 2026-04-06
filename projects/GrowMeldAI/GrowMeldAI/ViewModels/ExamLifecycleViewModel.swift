// ViewModels/ExamLifecycleViewModel.swift
import Foundation
import Combine

/// Single source of truth for exam stage and countdown
/// Injected into all views needing stage-aware messaging
class ExamLifecycleViewModel: ObservableObject {
    @Published var currentStage: ExamStage = .earlyPrep
    @Published var daysUntilExam: Int = 0
    @Published var examDate: Date?
    
    private let userProfileService: UserProfileService
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
        
        // Observe exam date changes
        userProfileService.$scheduledExamDate
            .sink { [weak self] _ in
                self?.updateStage()
            }
            .store(in: &cancellables)
        
        startMonitoring()
    }
    
    /// Begin hourly stage recalculation
    func startMonitoring() {
        updateStage()
        
        // Recalculate every hour in case time has passed
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateStage()
        }
    }
    
    /// Stop monitoring (call on deinit or when no longer needed)
    func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateStage() {
        if let date = userProfileService.scheduledExamDate {
            let components = Calendar.current.dateComponents([.day], from: Date(), to: date)
            let days = components.day ?? 0
            
            daysUntilExam = max(0, days)  // Never negative
            currentStage = ExamStage(daysUntilExam: daysUntilExam)
            examDate = date
        }
    }
    
    deinit {
        stopMonitoring()
    }
}