// Models/ExamProximity.swift
import Foundation

struct ExamProximity: Sendable {
    let daysRemaining: Int
    let categoryFocus: String
    
    var motivationalMessage: String {
        switch daysRemaining {
        case 7:
            return String(format: NSLocalizedString("exam.days.7", comment: ""), categoryFocus)
        case 3:
            return NSLocalizedString("exam.days.3", comment: "")
        case 1:
            return NSLocalizedString("exam.days.1", comment: "")
        case 0:
            return NSLocalizedString("exam.today", comment: "")
        default:
            return String(format: NSLocalizedString("exam.days.default", comment: ""), daysRemaining, categoryFocus)
        }
    }
    
    var retrievalInterval: TimeInterval {
        daysRemaining <= 3 ? 3600 : 86400 // 1h vs 24h
    }
}