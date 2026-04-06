// Models/IdentificationResult.swift
import Foundation

struct IdentificationResult: Codable {
    let name: String
    let confidence: Double
    let category: Category
    let description: String
    let learningPath: [Question.Category] // NEW: For competence feedback

    enum Category: String, Codable {
        case trafficSign = "traffic_sign"
        case roadMarking = "road_marking"
        case vehicle = "vehicle"
    }
}

extension IdentificationResult {
    static var mock: IdentificationResult {
        IdentificationResult(
            name: "Stoppschild",
            confidence: 0.98,
            category: .trafficSign,
            description: "Rotes achteckiges Schild mit 'STOP'",
            learningPath: [.trafficSigns, .rightOfWay]
        )
    }
}