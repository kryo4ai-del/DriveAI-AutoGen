import Foundation

struct AnswerConfidence {
    let score: Double // 0.0 – 1.0

    var label: String {
        switch score {
        case 0.75...: return "High"
        case 0.40...: return "Medium"
        default:      return "Low"
        }
    }

    var percentage: Int { Int(score * 100) }
}
