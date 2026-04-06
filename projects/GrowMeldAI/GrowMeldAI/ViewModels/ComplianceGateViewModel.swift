// ViewModels/ComplianceGateViewModel.swift

@MainActor
final class ComplianceGateViewModel: ObservableObject {
    @Published var complianceProfile: ComplianceProfile?
    @Published var showsAgeVerification = false
    @Published var showsParentalConsent = false
    @Published var showsConsentBanner = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let complianceService: ComplianceService
    private let geolocationService: GeolocationService
    
    init(
        complianceService: ComplianceService = .shared,
        geolocationService: GeolocationService = .shared
    ) {
        self.complianceService = complianceService
        self.geolocationService = geolocationService
    }
    
    // MARK: - Initialization
    
    func initializeCompliance() async {
        isLoading = true
        defer { isLoading = false }
        
        // Step 1: Check for cached profile
        if let cached = complianceService.loadCachedProfile() {
            self.complianceProfile = cached
            return
        }
        
        // Step 2: Detect jurisdiction
        let jurisdiction = await geolocationService.detectJurisdiction()
        
        // Step 3: Show age verification (required for both GDPR + COPPA)
        self.showsAgeVerification = true
        
        // Initialize with unknown profile
        self.complianceProfile = ComplianceProfile(
            ageGroup: .unknown,
            jurisdiction: jurisdiction,
            verificationDate: Date(),
            hasParentalConsent: false
        )
    }
    
    // MARK: - Age Verification
    
    func submitAgeVerification(birthYear: Int) async {
        guard var profile = complianceProfile else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let age = Calendar.current.component(.year, from: Date()) - birthYear
        profile.ageGroup = age >= 16 ? .adult : .child
        profile.verificationDate = Date()
        
        self.complianceProfile = profile
        self.showsAgeVerification = false
        
        // If COPPA applies (child in U.S.), show parental consent
        if profile.requiresParentalConsent {
            self.showsParentalConsent = true
        } else {
            // Otherwise, proceed to GDPR consent banner
            self.showsConsentBanner = true
            await complianceService.saveCachedProfile(profile)
        }
    }
    
    // MARK: - Parental Consent (COPPA)
    
    func submitParentalConsent(parentEmail: String) async {
        guard var profile = complianceProfile else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let verified = try await complianceService.verifyParentalConsent(parentEmail)
            
            if verified {
                profile.hasParentalConsent = true
                self.complianceProfile = profile
                self.showsParentalConsent = false
                self.showsConsentBanner = true
                await complianceService.saveCachedProfile(profile)
            } else {
                self.error = "Überprüfung fehlgeschlagen. Bitte versuchen Sie es später erneut."
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - GDPR Consent Banner
    
    func submitConsentDecision(
        analyticsAllowed: Bool,
        marketingAllowed: Bool
    ) async {
        guard let profile = complianceProfile else { return }
        
        let decision = ConsentDecision(
            timestamp: Date(),
            analyticsAllowed: analyticsAllowed,
            marketingAllowed: marketingAllowed,
            complianceProfile: profile
        )
        
        await complianceService.recordConsentDecision(decision)
        self.showsConsentBanner = false
    }
}

struct ConsentDecision: Codable {
    let timestamp: Date
    let analyticsAllowed: Bool
    let marketingAllowed: Bool
    let complianceProfile: ComplianceProfile
}