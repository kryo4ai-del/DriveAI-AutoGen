class NotificationRateLimiter {
       private let maxPerDay: [NotificationType: Int] = [
           .examReadinessCheckpoint: 1,
           .weakAreaAlert: 1,
           .streakMilestone: 1,
           .examDateReminder: 1,
           .dailyMotivation: 1
       ]
       
       func canSend(_ type: NotificationType) async -> Bool {
           let sentToday = try await auditService.countToday(for: type)
           return sentToday < (maxPerDay[type] ?? 1)
       }
   }