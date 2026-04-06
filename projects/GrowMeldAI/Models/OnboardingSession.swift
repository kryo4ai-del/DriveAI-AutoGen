struct OnboardingSession {
    var profileData: UserProfileData?
}

// In ViewModel:
var session: OnboardingSession = ...
session.profileData?.name = "Changed"  // Mutates the stored data!