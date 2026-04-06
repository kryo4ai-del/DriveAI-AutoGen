import Foundation

enum StudyOption: Identifiable, Hashable {
    case strengthenWeakCategory(categoryName: String, currentScore: Int)
    case quickDrill(questionCount: Int, estimatedMinutes: Int)
    case focusedReview(category: String, lastReviewedDate: Date)
    case examSimulation
    
    var id: String {
        switch self {
        case .strengthenWeakCategory(let name, _): return "weak-\(name)"
        case .quickDrill: return "quick-drill"
        case .focusedReview(let cat, _): return "review-\(cat)"
        case .examSimulation: return "exam-sim"
        }
    }
    
    var displayLabel: String {
        switch self {
        case .strengthenWeakCategory(let name, _):
            return "📍 \(name) stärken"
        case .quickDrill(let count, let minutes):
            return "⚡ Schnell-Check: \(count) Fragen in \(minutes) Min"
        case .focusedReview(let category, _):
            return "🔄 \(category) auffrischen"
        case .examSimulation:
            return "🎯 Prüfungs-Simulation"
        }
    }
    
    var motivationalMessage: String {
        switch self {
        case .strengthenWeakCategory(_, let score):
            return "Von \(score)% → 80%? In 3 Tagen erreichbar!"
        case .quickDrill:
            return "Schnell Vertrauen aufbauen. Nur 5 Minuten."
        case .focusedReview:
            return "Auffrischung fällig—ideal vor der Prüfung."
        case .examSimulation:
            return "Teste dich unter echten Bedingungen."
        }
    }
}