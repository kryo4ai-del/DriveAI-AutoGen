struct OnboardingContext {
    let capturedImage: UIImage?
    let userProfile: UserProfile?
}

@Published private(set) var state: OnboardingState = .welcome
@Published private(set) var context: OnboardingContext = .init(capturedImage: nil, userProfile: nil)