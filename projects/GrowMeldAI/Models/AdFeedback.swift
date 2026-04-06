import Foundation

struct AdFeedback: Equatable {
    let questionsReviewedCount: Int
    let confidenceIncreasePercent: Double
    let campaignId: String
    let categoryFeedback: [QuestionCategory: Double]

    enum QuestionCategory: String, CaseIterable, Codable {
        case rightOfWay = "Vorfahrt"
        case speed = "Geschwindigkeit"
        case signs = "Verkehrszeichen"
        case parking = "Parken"
        case general = "Allgemein"
    }

    init(questionsReviewedCount: Int,
         confidenceIncreasePercent: Double,
         campaignId: String,
         categoryFeedback: [QuestionCategory: Double] = [:]) {
        self.questionsReviewedCount = questionsReviewedCount
        self.confidenceIncreasePercent = max(0, min(confidenceIncreasePercent, 100))
        self.campaignId = campaignId
        self.categoryFeedback = categoryFeedback
    }
}