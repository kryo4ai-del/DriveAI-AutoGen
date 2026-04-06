class PreferencesService {
    enum PreferencesError: LocalizedError {
        case encodingFailed(Error)
        case decodingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed(let error):
                return "Failed to save profile: \(error.localizedDescription)"
            case .decodingFailed(let error):
                return "Failed to load profile: \(error.localizedDescription)"
            }
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) throws {
        do {
            let encoded = try encoder.encode(profile)
            userDefaults.set(encoded, forKey: profileKey)
        } catch {
            throw PreferencesError.encodingFailed(error)
        }
    }
    
    func loadUserProfile() throws -> UserProfile? {
        guard let data = userDefaults.data(forKey: profileKey) else { return nil }
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw PreferencesError.decodingFailed(error)
        }
    }
}

// Update AppState:
func loadUserProfile() async {
    do {
        if let saved = try preferencesService.loadUserProfile() {
            self.userProfile = saved
        } else {
            self.userProfile = UserProfile.default
        }
    } catch {
        // Log error, show alert to user
        print("❌ Failed to load profile: \(error)")
        self.userProfile = UserProfile.default
    }
}