import Foundation
struct ConversionFunnel: Codable {
    let userID: UUID
    var stages: [Stage] = []  // Timestamps can re-identify user
}