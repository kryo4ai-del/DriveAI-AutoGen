// Models/ExamDateValidator.swift
import Foundation
struct ExamDateValidator {
    static func validate(_ date: Date) -> (isValid: Bool, error: String?) {
        let now = Date()
        let calendar = Calendar.current
        
        let tomorrowStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        
        guard date >= tomorrowStart else {
            return (false, "Dein Prüfungstermin muss in der Zukunft liegen")
        }
        
        let maxDate = calendar.date(byAdding: .year, value: 2, to: now)!
        guard date <= maxDate else {
            return (false, "Bitte wähle ein realistisches Datum")
        }
        
        return (true, nil)
    }
}