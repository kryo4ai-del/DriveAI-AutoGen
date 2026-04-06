// Models/AIFallbackModels.swift
import Foundation

enum ExamStage {
    case earlyPrep          // 30+ days
    case midStudy           // 7-14 days
    case finalCramming      // 1-6 days
    
    init(daysUntilExam: Int) {
        if daysUntilExam >= 30 {
            self = .earlyPrep
        } else if daysUntilExam >= 7 {
            self = .midStudy
        } else {
            self = .finalCramming
        }
    }
}

struct QuestionMetadata {
    let examFrequencyPercent: Int?  // e.g., 35 for 35%
    let userAccuracyPercent: Int?   // user's answer rate on this question
    let isHighFocusArea: Bool       // marked weakness
    let officialSourceLabel: String // "Amtliche Fragenkatalog"
}

struct FallbackMessage {
    let primary: String
    let secondary: String?
    let tone: MessageTone
    
    enum MessageTone {
        case reassuring
        case neutral
        case motivational
    }
}