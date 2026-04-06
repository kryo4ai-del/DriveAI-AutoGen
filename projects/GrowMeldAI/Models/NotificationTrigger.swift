enum NotificationTrigger {
       case examCompletion
       case streakMilestone
       case categoryMilestone
       case dailyReminder
   }
   
   // ❌ User cannot consent to just "exam reminders" without also accepting "streak milestones"