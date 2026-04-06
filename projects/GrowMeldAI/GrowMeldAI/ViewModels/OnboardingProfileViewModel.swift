import Combine

@MainActor
final class OnboardingProfileViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var examDate: Date = Date.minimumExamDate()
    @Published var licenseCategory: LicenseCategory = .b
    @Published var formErrors: [FormField: String] = [:]
    
    enum FormField: String, CaseIterable {
        case name, examDate, licenseCategory
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupValidationObservers()
    }
    
    // MARK: - Validation
    
    var isValidForm: Bool {
        FormField.allCases.allSatisfy { formErrors[$0] == nil }
    }
    
    private func setupValidationObservers() {
        // Validate name in real-time
        $name
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] newName in
                self?.validateName(newName)
            }
            .store(in: &cancellables)
        
        // Validate exam date when changed
        $examDate
            .sink { [weak self] newDate in
                self?.validateExamDate(newDate)
            }
            .store(in: &cancellables)
    }
    
    func validateField(_ field: FormField) {
        switch field {
        case .name:
            validateName(name)
        case .examDate:
            validateExamDate(examDate)
        case .licenseCategory:
            // License category always valid if selected
            formErrors.removeValue(forKey: .licenseCategory)
        }
    }
    
    private func validateName(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        
        if trimmed.isEmpty {
            formErrors[.name] = OnboardingStrings.Validation.emptyName
            announceError(OnboardingStrings.Validation.emptyName)
        } else if trimmed.count < OnboardingConstraints.minNameLength {
            formErrors[.name] = OnboardingStrings.Validation.nameTooShort
            announceError(OnboardingStrings.Validation.nameTooShort)
        } else if trimmed.containsOnlyValidNameCharacters == false {
            formErrors[.name] = OnboardingStrings.Validation.invalidNameCharacters
            announceError(OnboardingStrings.Validation.invalidNameCharacters)
        } else {
            formErrors.removeValue(forKey: .name)
        }
    }
    
    private func validateExamDate(_ date: Date) {
        let minimumDate = Date.minimumExamDate()
        
        if date < minimumDate {
            formErrors[.examDate] = OnboardingStrings.Validation.examDateTooSoon
            announceError(OnboardingStrings.Validation.examDateTooSoon)
        } else {
            formErrors.removeValue(forKey: .examDate)
        }
    }
    
    // MARK: - Accessibility
    
    private func announceError(_ message: String) {
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }
    
    // MARK: - Form Submission
    
    func submitForm() throws -> UserProfileData {
        // Validate all fields
        validateField(.name)
        validateField(.examDate)
        validateField(.licenseCategory)
        
        guard isValidForm else {
            throw OnboardingError.invalidProfileData(
                reason: NSLocalizedString(
                    "error.form.invalid",
                    value: "Bitte füllen Sie alle Felder korrekt aus.",
                    comment: "Form has validation errors"
                )
            )
        }
        
        // Create profile
        let profile = UserProfileData.new(
            name: name,
            examDate: examDate,
            licenseCategory: licenseCategory
        )
        
        return profile
    }
}