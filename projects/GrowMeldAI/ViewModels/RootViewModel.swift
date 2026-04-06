import Foundation
import SwiftUI

@MainActor
final class RootViewModel: ObservableObject {
    @Published var currentScreen: RootScreen = .splash
    @Published var isInitializing = true
    @Published var error: AppError?
    
    @ObservedObject var regionManager: RegionManager
    @ObservedObject var preferencesService: UserPreferencesService
    
    enum RootScreen: Hashable {
        case splash
        case regionSelection
        case examDatePicker
        case regionalQuiz
        case home
    }
    
    init(
        regionManager: RegionManager,
        preferencesService: UserPreferencesService
    ) {
        self.regionManager = regionManager
        self.preferencesService = preferencesService
        
        Task {
            await determineInitialScreen()
        }
    }
    
    // MARK: - Navigation Transitions
    
    func completeRegionSelection(region: Region) async {
        do {
            try await regionManager.switchRegion(region)
            currentScreen = .examDatePicker
        } catch {
            self.error = AppError.regionSwitchFailed(error.localizedDescription)
        }
    }
    
    func completeExamDateSelection(_ date: Date) async {
        preferencesService.setExamDate(date, for: regionManager.currentRegion)
        currentScreen = .regionalQuiz
    }
    
    func completeRegionalQuiz() async {
        preferencesService.markOnboardingComplete()
        currentScreen = .home
    }
    
    func skipRegionalQuiz() async {
        preferencesService.markOnboardingComplete()
        currentScreen = .home
    }
    
    func resetToOnboarding() async {
        preferencesService.reset()
        currentScreen = .regionSelection
        error = nil
    }
    
    // MARK: - Private Helpers
    
    private func determineInitialScreen() async {
        defer { isInitializing = false }
        
        if preferencesService.hasCompletedOnboarding {
            currentScreen = .home
        } else {
            currentScreen = .regionSelection
        }
    }
}

// MARK: - Error Model
