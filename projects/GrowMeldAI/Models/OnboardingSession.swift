struct OnboardingSession {
    var profileData: UserProfileData?
}

struct UserProfileData {
    var name: String
}

// In ViewModel:
var session = OnboardingSession()
session.profileData = UserProfileData(name: "Initial")
session.profileData?.name = "Changed"  // Mutates the stored data!