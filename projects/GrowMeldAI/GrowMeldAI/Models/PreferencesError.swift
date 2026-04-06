enum PreferencesError: LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let reason):
            return "Could not save profile: \(reason)"
        case .decodingFailed(let reason):
            return "Could not load profile: \(reason)"
        }
    }
}

// In AppState:
@MainActor
func loadUserProfile() async {
    do {
        self.userProfile = try preferencesService.loadUserProfile() ?? UserProfile.default
    } catch {
        print("❌ Profile load failed: \(error.localizedDescription)")
        self.userProfile = UserProfile.default
        // TODO: Show error alert to user
    }
}