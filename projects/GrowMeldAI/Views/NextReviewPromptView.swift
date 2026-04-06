struct NextReviewPromptView: View {
    let date: Date
    let daysRemaining: Int
    
    var isOverdue: Bool { daysRemaining < 0 }
    var urgency: String {
        isOverdue ? "Deine Wiederholung ist überfällig!" : "Zeit zum Lernen!"
    }
}