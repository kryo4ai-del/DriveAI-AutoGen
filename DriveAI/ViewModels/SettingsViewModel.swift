import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var examDate: Date {
        didSet { saveExamDate() }
    }
    
    @Published var enableHaptics: Bool {
        didSet { UserDefaults.standard.set(enableHaptics, forKey: "haptics_enabled") }
    }
    
    @Published var textSizeMultiplier: Double {
        didSet { UserDefaults.standard.set(textSizeMultiplier, forKey: "text_size_multiplier") }
    }
    
    @Published var showResetConfirmation = false
    @Published var resetSuccess = false
    
    private let localDataService: LocalDataService
    private let defaults = UserDefaults.standard
    
    // MARK: - Init
    init(localDataService: LocalDataService = .shared) {
        self.localDataService = localDataService
        
        // Load persisted values
        self.examDate = localDataService.loadExamDate() ?? Date()
        self.enableHaptics = defaults.bool(forKey: "haptics_enabled") || true
        self.textSizeMultiplier = defaults.double(forKey: "text_size_multiplier") == 0 
            ? 1.0 
            : defaults.double(forKey: "text_size_multiplier")
    }
    
    // MARK: - Methods
    func resetProgress() {
        localDataService.resetAllProgress()
        resetSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetSuccess = false
        }
    }
    
    private func saveExamDate() {
        localDataService.saveExamDate(examDate)
    }
}