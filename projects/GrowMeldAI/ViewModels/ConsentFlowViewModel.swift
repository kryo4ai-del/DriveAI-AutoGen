@MainActor
class ConsentFlowViewModel: ObservableObject {
    @Published var categories: [ConsentCategoryUI] = []
    @Published var selectedConsents: [ConsentCategory: Bool] = [:]
    @Published var canProceed: Bool = false
    
    private let consentManager: ConsentManager
    
    func updateConsent(_ category: ConsentCategory, granted: Bool) {
        selectedConsents[category] = granted
        canProceed = validateConsents()
    }
    
    func finalizeConsents() async throws {
        try await consentManager.saveConsents(selectedConsents)
        // Audit logged internally
    }
}