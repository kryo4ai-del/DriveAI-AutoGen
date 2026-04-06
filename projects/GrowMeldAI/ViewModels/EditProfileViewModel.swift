import Foundation

enum ProfileError: LocalizedError {
    case invalidName
    case invalidExamDate
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Bitte gib einen gültigen Namen ein."
        case .invalidExamDate:
            return "Das Prüfungsdatum muss in der Zukunft liegen."
        case .saveFailed(let reason):
            return "Speichern fehlgeschlagen: \(reason)"
        }
    }
}

protocol UserProfileServiceProtocol {
    func saveProfile(_ profile: UserProfile) async throws
}

struct UserProfile: Codable {
    enum StudyGoal: String, Codable, CaseIterable {
        case quick
        case balanced
        case thorough
    }

    var id: UUID
    var name: String
    var examDate: Date
    var studyGoal: StudyGoal

    init(name: String, examDate: Date, studyGoal: StudyGoal) {
        self.id = UUID()
        self.name = name
        self.examDate = examDate
        self.studyGoal = studyGoal
    }
}

@MainActor
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

            try await profileService.saveProfile(profile)
        } catch {
            validationError = error.localizedDescription
        }
    }
}