// Models/MotivationalMessage.swift
enum MessageKey: String {
    case beginnerTimeLeft = "msg.beginner.timeLeft"
    case beginnerDailyQuestions = "enc.beginner.dailyQuestions"
    case beginnerMilestone = "milestone.30percent"
    
    case intermediateProgress = "msg.intermediate.progress"
    case advancedReady = "msg.advanced.ready"
    case expertConfident = "msg.expert.confident"
    
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}
