enum OnboardingError: LocalizedError, Equatable {
    case dateTooFar(maxDays: Int)
}