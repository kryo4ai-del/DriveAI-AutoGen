// ViewModels/UserProfileViewModel.swift
import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile = .empty()
    @Published var isLoading = false
    @Published var error: UserProfileError?
    
    private let service: UserProfileServiceProtocol
    
    init(service: UserProfileServiceProtocol = UserProfileService.shared) {
        self.service = service
    }
    
    func loadProfile() {
        isLoading = true
        Task {
            do {
                userProfile = try await service.loadProfile()
                error = nil
            } catch let err as UserProfileError {
                error = err
            } catch {
                error = .loadFailed(error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    func updateExamDate(_ date: Date) {
        Task {
            do {
                userProfile.examDate = date
                try await service.saveProfile(userProfile)
                error = nil
            } catch let err as UserProfileError {
                error = err
            } catch {
                error = .saveFailed(error.localizedDescription)
            }
        }
    }
    
    func recordQuestionResult(categoryId: String, categoryName: String, correct: Bool) {
        Task {
            do {
                try await service.updateProgress(categoryId: categoryId, correct: correct, categoryName: categoryName)
                userProfile = try await service.loadProfile()
                error = nil
            } catch let err as UserProfileError {
                error = err
            } catch {
                error = .saveFailed(error.localizedDescription)
            }
        }
    }
    
    var daysUntilExam: Int? {
        guard let examDate = userProfile.examDate else { return nil }
        return Calendar.current.dateComponents([.day], from: .now, to: examDate).day ?? 0
    }
}

// ViewModels/ProfileDashboardViewModel.swift
@MainActor
final class ProfileDashboardViewModel: ObservableObject {
    @Published var daysUntilExam: Int?
    @Published var attemptCount: Int = 0
    @Published var currentStreak: Int = 0
    @Published var topCategories: [CategoryProgress] = []
    @Published var totalMastery: Double = 0
    
    private let profileVM: UserProfileViewModel
    
    init(_ profileVM: UserProfileViewModel) {
        self.profileVM = profileVM
        updateMetrics()
    }
    
    private func updateMetrics() {
        daysUntilExam = profileVM.daysUntilExam
        attemptCount = profileVM.userProfile.attemptCount
        currentStreak = profileVM.userProfile.currentStreak
        topCategories = profileVM.userProfile.categoryProgress.values
            .sorted { $0.masteryPercentage > $1.masteryPercentage }
            .prefix(3)
            .map { $0 }
        totalMastery = profileVM.userProfile.categoryProgress.values.isEmpty 
            ? 0 
            : profileVM.userProfile.categoryProgress.values.map { $0.masteryPercentage }.reduce(0, +) / Double(profileVM.userProfile.categoryProgress.count)
    }
}