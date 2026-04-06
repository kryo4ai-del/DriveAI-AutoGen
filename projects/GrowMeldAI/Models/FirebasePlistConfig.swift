import Foundation

/// Build-time configuration reference.
struct FirebasePlistConfig {
    /// Path to GoogleService-Info.plist
    /// ⚠️ This file is .gitignored and provisioned by CI/CD only.
    static let googleServiceInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    
    static var isPlistAvailable: Bool {
        return googleServiceInfoPath != nil
    }
}