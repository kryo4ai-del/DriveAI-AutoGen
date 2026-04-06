// ViewModels/EditProfileViewModel.swift - FIXED
import Foundation

class EditProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var examDate: Date
    @Published var selectedGoal: UserProfile.StudyGoal = .thorough
    @Published var validationError: String?
    @Published var isSaving = false
    
    private let profileService: UserProfileServiceProtocol
    private var originalProfile: UserProfile?
    
    init(profileService: UserProfileServiceProtocol, profile: UserProfile? = nil) {
        self.profileService = profileService
        self.examDate = profile?.examDate ?? Date().addingTimeInterval(86400 * 30)
        
        if let profile = profile {
            self.name = profile.name
            self.examDate = profile.examDate
            self.selectedGoal = profile.studyGoal
            self.originalProfile = profile
        }
    }
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        examDate > Date()
    }
    
    @MainActor
    func saveProfile() async {
        validationError = nil
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            validationError = ProfileError.invalidName.localizedDescription
            return
        }
        
        guard examDate > Date() else {
            validationError = ProfileError.invalidExamDate.localizedDescription
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            var profile = originalProfile ?? UserProfile(
                name: trimmedName,
                examDate: examDate,
                studyGoal: selectedGoal
            )
            
            profile.name = trimmedName
            profile.examDate = examDate
            profile.studyGoal = selectedGoal
            
            try await profileService.updateProfile(profile)
        } catch {
            validationError = error.localizedDescription
        }
    }
}