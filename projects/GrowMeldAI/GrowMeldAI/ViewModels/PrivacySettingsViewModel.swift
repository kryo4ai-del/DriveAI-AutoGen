@MainActor
class PrivacySettingsViewModel: ObservableObject {
    @Published var privacySettings: PrivacySettings
    @Published var isDeletingAccount = false
    @Published var deleteError: String?
    
    private let consentManager: ConsentManager
    private let deletionService: DataDeletionService
    
    func revokeConsent(_ category: ConsentCategory) async {
        await consentManager.revokeConsent(category)
        // Triggers immediate data purge via PrivacyDataStore
    }
    
    func initiateAccountDeletion() async throws {
        try await deletionService.scheduleForDeletion(
            userId: currentUserID,
            gracePeriod: 30
        )
    }
}