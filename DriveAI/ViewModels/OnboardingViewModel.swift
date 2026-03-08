// ViewModels/OnboardingViewModel.swift
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    private let screens: [OnboardingScreenModel] = [
        OnboardingScreenModel(title: "Welcome to DriveAI", description: "Learn to drive with confidence!", imageName: "welcome_image"),
        OnboardingScreenModel(title: "Track Your Progress", description: "Monitor your preparation for the driver's license exam.", imageName: "progress_image"),
        OnboardingScreenModel(title: "Get Started", description: "Select your exam date and start your journey.", imageName: "start_image")
    ]
    
    var totalPages: Int {
        screens.count
    }

    func nextPage(completion: (() -> Void)? = nil) {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
        completion?()
    }

    func skipOnboarding() {
        currentPage = totalPages - 1 // Directly navigate to the last page
    }

    func screen(for index: Int) -> OnboardingScreenModel {
        return screens[index]
    }
}