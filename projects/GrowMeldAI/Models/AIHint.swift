import Foundation

struct AIHint: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let text: String
    let source: HintSource
    let confidence: Double  // 0.0–1.0
    
    enum HintSource: String, Codable, Sendable {
        case ai
        case official
        case fallback
    }
    
    init(
        id: String = UUID().uuidString,
        text: String,
        source: HintSource = .official,
        confidence: Double = 1.0
    ) {
        self.id = id
        self.text = text
        self.source = source
        self.confidence = confidence
    }
}