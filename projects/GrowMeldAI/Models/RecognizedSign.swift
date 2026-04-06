import Foundation

struct RecognizedSign: Equatable, Sendable, Identifiable {
    let id: String  // Sign identifier from database
    let name: String  // Localized sign name
    let confidence: Float  // 0.0-1.0
    let imageName: String  // For UI display
    let category: String  // e.g., "warning", "prohibition"
    let timestamp: Date
    
    var signID: String { id }
}