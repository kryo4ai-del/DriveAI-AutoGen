import Foundation

enum QuestionType: String, Codable, CaseIterable {
    case recall      = "Recall"
    case application = "Anwendung"
    case hazard      = "Gefahrensituation"

    /// Formatted micro-label, e.g. "Recall: Verkehrszeichen"
    func microLabel(for topic: TopicArea) -> String {
        "\(rawValue): \(topic.displayName)"
    }
}
