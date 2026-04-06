@MainActor
class UserProfileManager {
    @Published var profile: UserProfile
    
    nonisolated func updateProfile(_ updates: (inout UserProfile) -> Void) {
        MainActor.assumeIsolated {
            updates(&profile)
        }
    }
}