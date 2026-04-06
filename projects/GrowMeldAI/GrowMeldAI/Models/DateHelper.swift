// Utilities/DateHelper.swift
import Foundation

enum DateHelper {
    /// Calculate days between now and target date
    static func daysFromNow(to targetDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    /// Natural language review timing (e.g., "Morgen üben")
    static func reviewTimingLabel(for targetDate: Date) -> String {
        let days = daysFromNow(to: targetDate)
        
        switch days {
        case ..<0:
            return "Überfällig"
        case 0:
            return "Heute üben"
        case 1:
            return "Morgen üben"
        case 2:
            return "Übermorgen"
        default:
            return "In \(days) Tagen"
        }
    }
    
    /// Detailed accessibility label
    static func accessibilityReviewLabel(for targetDate: Date) -> String {
        let days = daysFromNow(to: targetDate)
        
        let dayText: String
        switch days {
        case ..<0: dayText = "überfällig"
        case 0: dayText = "heute"
        case 1: dayText = "morgen"
        default: dayText = "in \(days) Tagen"
        }
        
        return "Nächste Wiederholung: \(dayText)"
    }
}