// Models/RemindersSettings.swift
@Model
final class ReminderSettings {
    var isEnabled: Bool = true
    var frameAsTestOpportunity: Bool = true  // UX psychology finding
    var intervals: [Int] = [1, 3, 7, 14]     // Days
    var showNextReviewDate: Bool = true      // Transparency requirement
    var optimalReviewWindow: DateInterval?   // User education
}

// Services/RemindersService.swift