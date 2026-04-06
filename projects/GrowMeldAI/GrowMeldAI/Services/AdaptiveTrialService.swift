protocol AdaptiveTrialService {
    /// Should we increase trial limits based on user engagement?
    func shouldOfferExtendedTrial(userMetrics: UserMetrics) -> Bool
    
    /// Should we offer targeted Premium feature (not full upgrade)?
    func shouldOfferTargetedPremium(weekAreas: [WeakArea]) -> TargetedUpgrade?
}

enum TargetedUpgrade {
    case weakAreaDrills(category: String)  // "Master right-of-way with focused drills"
    case examSimulation  // "Try 1 timed 30-question exam"
    case noCTA  // User is engaged, don't interrupt
}