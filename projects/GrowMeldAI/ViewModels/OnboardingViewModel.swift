import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var stage: OnboardingStage = .welcome
    @Published var selectedExamDate = Date().addingTimeInterval(30 * 24 * 3600) // 30 days
    @Published var allowsCrashReporting = true
    @Published var isLoading = false
    @Published var error: String?
    
    enum OnboardingStage {
        case welcome
        case examDate
        case privacyConsent
        case complete
    }
    
    var nextButtonText: String {
        switch stage {
        case .welcome:
            return "Weiter"
        case .examDate:
            return "Weiter"
        case .privacyConsent:
            return "Fertig"
        case .complete:
            return "Home"
        }
    }
    
    var canGoBack: Bool {
        stage != .welcome
    }
    
    var isNextButtonEnabled: Bool {
        !isLoading
    }
    
    var daysUntilExam: Int? {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: selectedExamDate).day
        return days ?? 0
    }
    
    func nextStage() async {
        isLoading = true
        defer { isLoading = false }
        
        switch stage {
        case .welcome:
            stage = .examDate
        case .examDate:
            stage = .privacyConsent
        case .privacyConsent:
            await saveOnboarding()
            stage = .complete
        case .complete:
            break
        }
    }
    
    func previousStage() {
        switch stage {
        case .welcome:
            break
        case .examDate:
            stage = .welcome
        case .privacyConsent:
            stage = .examDate
        case .complete:
            stage = .privacyConsent
        }
    }
    
    private func saveOnboarding() async {
        do {
            var user = User.default
            user.examDate = selectedExamDate
            user.crashReportingConsent = allowsCrashReporting
            
            try await UserDataManager.shared.saveUser(user)
            try await UserDataManager.shared.markOnboardingComplete()
        } catch {
            self.error = "Fehler beim Speichern: \(error.localizedDescription)"
        }
    }
}