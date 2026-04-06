// NEW: Add to Recommendation
struct Recommendation {
    // ... existing fields ...
    let examRelevance: ExamRelevance?  // How often this appears on actual exams
    let timeUntilExam: Int?            // Days left to prepare
    
    enum ExamRelevance {
        case highFrequency(appearsInPercent: Int)  // "Appears in 27% of questions"
        case commonMistake(percentageWhoFail: Int) // "34% of candidates fail this"
        case keyTopic                               // "Foundation for multiple areas"
    }
}

// In recommendation copy:
var strategicCopy: String {
    switch examRelevance {
    case .highFrequency(let percent):
        return "Verkehrsschilder: Kommt in \(percent)% der echten Prüfungen vor. Die beste ROI für deine Zeit."
    case .commonMistake(let percentFail):
        return "Vorfahrtsregeln: \(percentFail)% der Kandidaten fallen hier durch. Typischer Schwachpunkt."
    case .keyTopic:
        return "Das ist Grundlagen-Wissen für mindestens 3 andere Kategorien. Meistern lohnt sich doppelt."
    default:
        return "Fokus auf diese Kategorie."
    }
}