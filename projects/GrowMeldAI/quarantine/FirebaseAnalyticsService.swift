// Services/Analytics/FirebaseAnalyticsService.swift
final class FirebaseAnalyticsService: AnalyticsService {
    private init() {
        configureFirebase()
    }
    
    private func configureFirebase() {
        // Firebase is configured in app startup
        // This initializer just prepares the service
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        #endif
    }
    
    // Factory method for proper DI
    static func make() throws -> AnalyticsService {
        guard FirebaseApp.app() != nil else {
            throw AnalyticsConfigError.firebaseNotInitialized
        }
        return FirebaseAnalyticsService()
    }
    
    // MARK: - AnalyticsService Conformance
    
    @MainActor
    func logEvent(_ event: AnalyticsEvent) async {
        guard event.isValid else {
            #if DEBUG
            print("❌ Invalid analytics event: \(event)")
            #endif
            return
        }
        
        let (eventName, parameters) = formatEvent(event)
        Analytics.logEvent(eventName, parameters: parameters)
        
        #if DEBUG
        print("📊 Analytics: \(eventName)")
        #endif
    }
    
    @MainActor
    func setUserProperty(_ property: UserProperty) async {
        Analytics.setUserProperty(property.value, forName: property.key)
        
        #if DEBUG
        print("👤 User property: \(property.key)")
        #endif
    }
    
    @MainActor
    func setUserID(_ userID: String) async {
        Analytics.setUserID(userID)
        
        #if DEBUG
        print("🔑 User ID set")
        #endif
    }
    
    @MainActor
    func reset() async {
        Analytics.resetAnalyticsData()
        
        #if DEBUG
        print("🔄 Analytics reset")
        #endif
    }
    
    // MARK: - Private Helpers
    
    private func formatEvent(_ event: AnalyticsEvent) -> (String, [String: Any]?) {
        switch event {
        case .userOnboardingStarted:
            return ("user_onboarding_started", nil)
        case .userOnboardingCompleted(let examDate, let language):
            return ("user_onboarding_completed", [
                "exam_date": ISO8601DateFormatter().string(from: examDate),
                "language": language
            ])
        case .questionAnswered(let qID, let cID, let correct, let time, let difficulty):
            return ("question_answered", [
                "question_id": qID,
                "category_id": cID,
                "is_correct": correct,
                "time_spent_ms": time,
                "difficulty": difficulty.rawValue
            ])
        case .questionViewed(let qID, let cID):
            return ("question_viewed", [
                "question_id": qID,
                "category_id": cID
            ])
        case .categoryBrowsed(let cID, let cName):
            return ("category_browsed", [
                "category_id": cID,
                "category_name": cName
            ])
        case .examSimulationStarted(let mode, let cID):
            var params: [String: Any] = ["mode": mode.rawValue]
            if let cID = cID {
                params["category_id"] = cID
            }
            return ("exam_simulation_started", params)
        case .examSimulationCompleted(let score, let maxScore, let pass, let time, let correct):
            return ("exam_simulation_completed", [
                "score": score,
                "max_score": maxScore,
                "pass_status": pass.rawValue,
                "time_taken_s": time,
                "questions_correct": correct
            ])
        case .streakMilestoneReached(let streak, let category):
            return ("streak_milestone_reached", [
                "streak_count": streak,
                "category": category
            ])
        case .profileViewedExamCountdown(let days):
            return ("profile_viewed_exam_countdown", [
                "days_until_exam": days
            ])
        case .screenViewed(let screenName):
            return ("screen_viewed", [
                "screen_name": screenName
            ])
        }
    }
}

// Error handling