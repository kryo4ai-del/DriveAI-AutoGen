import Foundation

struct BreathPhase: Identifiable {
    let label: String
    let duration: Double
    
    var id: String { "\(label)-\(Int(duration))" }
}