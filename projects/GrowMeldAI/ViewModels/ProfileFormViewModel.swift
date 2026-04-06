// Features/Onboarding/ViewModels/ProfileFormViewModel.swift
@MainActor
final class ProfileFormViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var selectedCategory: LicenseCategory = .b
    @Published var examDate: Date?
    
    @Published var firstNameError: String?
    @Published var lastNameError: String?
    
    var isFormValid: Bool {
        validateFirstName() && validateLastName()
    }
    
    private func validateFirstName() -> Bool {
        let trimmed = firstName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            firstNameError = "Vorname erforderlich"
            return false
        }
        if trimmed.count < 2 {
            firstNameError = "Mindestens 2 Zeichen"
            return false
        }
        firstNameError = nil
        return true
    }
    
    private func validateLastName() -> Bool {
        let trimmed = lastName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            lastNameError = "Nachname erforderlich"
            return false
        }
        if trimmed.count < 2 {
            lastNameError = "Mindestens 2 Zeichen"
            return false
        }
        lastNameError = nil
        return true
    }
    
    func buildProfile(with id: String = UUID().uuidString) -> UserProfile? {
        guard isFormValid else { return nil }
        
        return UserProfile(
            id: id,
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            licenseCategory: selectedCategory,
            examDate: examDate
        )
    }
}