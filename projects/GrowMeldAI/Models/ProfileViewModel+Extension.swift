// ✅ GOOD: Testable
extension ProfileViewModel {
    var isExamUrgent: Bool {
        daysUntilExam < 7 && daysUntilExam >= 0
    }
    
    var examCountdownText: String {
        switch daysUntilExam {
        case ..<0: return "Prüfung vorbei"
        case 0: return "Heute ist der Tag!"
        case 1: return "Morgen ist die Prüfung!"
        default: return "\(daysUntilExam) Tage"
        }
    }
}