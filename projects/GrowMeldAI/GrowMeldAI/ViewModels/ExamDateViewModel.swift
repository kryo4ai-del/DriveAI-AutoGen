// ✅ FIXED: ExamDateViewModel.swift

import Foundation

@MainActor
final class ExamDateViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var daysUntilExam: Int = 0
    @Published var studyRecommendation: String = ""
    @Published var dateError: String?
    
    private let minimumDaysToExam = 7
    
    func selectDate(_ date: Date) {
        selectedDate = date
        updateCountdown()
    }
    
    private func updateCountdown() {
        guard let date = selectedDate else {
            daysUntilExam = 0
            dateError = nil
            studyRecommendation = ""
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: date)
        
        let components = Calendar.current.dateComponents([.day], from: today, to: selectedDay)
        daysUntilExam = components.day ?? 0
        
        validateDate()
        generateStudyPlan()
    }
    
    private func validateDate() {
        dateError = nil
        
        if daysUntilExam < minimumDaysToExam {
            dateError = "Prüfung muss mindestens 7 Tage entfernt sein"
        }
    }
    
    private func generateStudyPlan() {
        guard dateError == nil else {
            studyRecommendation = ""
            return
        }
        
        switch daysUntilExam {
        case 0..<14:
            studyRecommendation = "🔥 Intensiv: 30–45 min täglich"
        case 14..<30:
            studyRecommendation = "⚡ Konzentriert: 20–30 min täglich"
        case 30..<60:
            studyRecommendation = "📚 Ausgewogen: 15–20 min täglich"
        default:
            studyRecommendation = "📅 Konstant: 10–15 min täglich"
        }
    }
    
    var isDateValid: Bool {
        dateError == nil && daysUntilExam >= minimumDaysToExam
    }
    
    func minSelectableDate() -> Date {
        Calendar.current.date(byAdding: .day, value: minimumDaysToExam, to: Date()) ?? Date()
    }
    
    func maxSelectableDate() -> Date {
        Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    }
}