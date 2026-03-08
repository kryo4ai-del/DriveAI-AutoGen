import Foundation

struct AnalysisResult {
    let id: UUID = UUID() // Added identifier for tracking
    let timestamp: Date = Date() // Timestamp of analysis
    let isRecognized: Bool
    let description: String // Description of analysis
}