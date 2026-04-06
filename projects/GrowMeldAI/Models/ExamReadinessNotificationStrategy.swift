class ExamReadinessNotificationStrategy {
    func shouldNotify(user: User, context: StudyContext) -> Bool {
        // Don't spam if user is already studying
        guard !context.isCurrentlyStudying else { return false }
        
        // Only if they have weak areas
        guard !context.weakAreas.isEmpty else { return false }
        
        // Respect quiet hours (e.g., 21:00–08:00)
        let now = Calendar.current.dateComponents([.hour], from: Date())
        guard (8...20).contains(now.hour ?? 0) else { return false }
        
        return true
    }
    
    func buildPayload(user: User, context: StudyContext) -> NotificationPayload {
        let weakestCategory = context.weakAreas.sorted { $0.errorRate > $1.errorRate }.first
        
        return NotificationPayload(
            type: .examReadinessCheckpoint,
            title: "Du bist 1 Schritt näher!",
            body: "Beantworte 3 Fragen zu \(weakestCategory?.name ?? "Verkehrszeichen")",
            deepLink: .practiceCategory(weakestCategory?.id),
            deliveryTime: .nextOptimalTime(for: user.timezone)
        )
    }
}