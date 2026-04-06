import SwiftUI

@MainActor
class AgeVerificationViewModel: ObservableObject {
    @Published var selectedBirthDate: Date = Date()
    @Published var ageVerified = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let service: ConsentRecordingService
    private let region: ComplianceRegion
    
    var birthYear: Int {
        Calendar.current.component(.year, from: selectedBirthDate)
    }
    
    var minimumAgeThreshold: Int {
        region.minimumAge
    }
    
    init(
        service: ConsentRecordingService = .shared,
        region: ComplianceRegion = Self.detectRegion()
    ) {
        self.service = service
        self.region = region
        
        // Load existing consent if available
        if service.hasValidConsent(for: region) {
            ageVerified = true
        }
    }
    
    func confirmAge() {
        // Clear previous error
        errorMessage = nil
        
        // Validate birthdate exists and is reasonable
        guard AgeCalculator.isValidBirthDate(selectedBirthDate) else {
            errorMessage = "Geburtsdatum liegt außerhalb des gültigen Bereichs"
            return
        }
        
        // Check age threshold
        guard AgeCalculator.isOldEnoughFor(
            region: region,
            birthDate: selectedBirthDate
        ) else {
            errorMessage = "Du musst mindestens \(region.minimumAge) Jahre alt sein"
            return
        }
        
        // Record consent
        isLoading = true
        
        let result = service.recordConsent(
            birthDate: selectedBirthDate,
            region: region,
            action: .confirmed
        )
        
        isLoading = false
        
        switch result {
        case .success:
            ageVerified = true
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func resetConsent() {
        ageVerified = false
        selectedBirthDate = Date()
        errorMessage = nil
    }
    
    // MARK: - Region Detection
    
    private static func detectRegion() -> ComplianceRegion {
        let locale = Locale.current
        
        // German-speaking regions get GDPR (16+)
        if locale.language.languageCode?.identifier == "de" {
            return .europeanUnion
        }
        
        // Detect via region
        if let region = locale.region?.identifier {
            switch region {
            case "DE", "AT", "CH":
                return .europeanUnion
            case "US":
                return .unitedStates
            case "GB":
                return .unitedKingdom
            default:
                return .europeanUnion // Default to strictest
            }
        }
        
        return .europeanUnion // Fallback to strictest
    }
}

// MARK: - Shared Singleton

extension ConsentRecordingService {
    static let shared = ConsentRecordingService()
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}