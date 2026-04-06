// Type-safe deep linking
enum ReminderDeepLink {
    case miniQuiz(category: String, readinessPercent: Int)
    
    init?(from userInfo: [AnyHashable: Any]) {
        guard let category = userInfo["category"] as? String,
              let readiness = userInfo["readiness"] as? Int else {
            return nil
        }
        self = .miniQuiz(category: category, readinessPercent: readiness)
    }
}

// In SceneDelegate or App:
func handleReminderDeepLink(_ link: ReminderDeepLink) {
    switch link {
    case .miniQuiz(let category, let readiness):
        navigationPath.append(.miniQuiz(category: category))
    }
}