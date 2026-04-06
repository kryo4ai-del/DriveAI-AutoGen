import Foundation

/// Maps category weakness to domain-specific root causes and prescriptions.
struct CoachingStrategy {
    static func analyze(
        categoryName: String,
        score: Double,
        reviewCount: Int,
        examDaysRemaining: Int,
        previousScores: [Double]
    ) -> (rootCause: String, prescription: String, estimatedMinutes: Int) {
        
        let improvement = previousScores.isEmpty ? 0 : score - previousScores.last!
        let trend = previousScores.count < 2 ? "stable" : (improvement > 0 ? "improving" : "declining")
        
        // Domain-specific root causes
        let rootCause: String
        let prescription: String
        let estimatedMinutes: Int
        
        switch (score, trend, categoryName.lowercased()) {
        case (0...3, _, "vorfahrtsregeln"), (0...3, _, "right-of-way"):
            rootCause = "Grundkonzept Vorfahrt nicht verstanden (z.B. grüner Pfeil)"
            prescription = "Theorie-Video anschauen, dann 5 Basis-Fragen üben"
            estimatedMinutes = 20
            
        case (4...6, "declining", let cat) where cat.contains("zeichen"):
            rootCause = "Verkehrszeichen verwirrt → langsamer Abruf"
            prescription = "Zeichen-Flash-Cards (10 Min), dann 3 Quiz-Fragen"
            estimatedMinutes = 15
            
        case (4...6, _, "geschwindigkeit"), (4...6, _, "speed"):
            rootCause = "Ausnahmeregelungen (z.B. Tempo-30-Zonen) unklar"
            prescription = "Spezielle Regel durcharbeiten, 3 Szenarien üben"
            estimatedMinutes = 12
            
        case (7...8, "stable", _):
            rootCause = "Gutes Grundwissen, aber 2–3 Lücken vorhanden"
            prescription = "Gezielt die schwächsten 2 Fragen wiederholen"
            estimatedMinutes = 8
            
        case (7...8, "declining", _):
            rootCause = "Konzentration lässt nach – wahrscheinlich Müdigkeit"
            prescription = "Kurze 5-Min-Pause, dann leichte Wiederholung"
            estimatedMinutes = 10
            
        case (9...10, _, _):
            rootCause = "Meisterhafte Beherrschung 🎓"
            prescription = "Weiter so! Nächste Wiederholung in 1 Woche."
            estimatedMinutes = 0
            
        default:
            rootCause = "Thema braucht Aufmerksamkeit"
            prescription = "Wiederhole die letzten Quiz-Fragen"
            estimatedMinutes = 10
        }
        
        // Adjust urgency based on exam timing
        if examDaysRemaining < 3 && score < 7 {
            return (
                "⚠️ " + rootCause,
                prescription + " (Deine Prüfung ist in \(examDaysRemaining) Tagen!)",
                estimatedMinutes
            )
        }
        
        return (rootCause, prescription, estimatedMinutes)
    }
}