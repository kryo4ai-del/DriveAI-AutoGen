// Models/IdentificationResult.swift
import Foundation

struct IdentificationResult: Codable, Equatable {
    let name: String
    let confidence: Double
    let category: IdentificationCategory
    let description: String

    enum IdentificationCategory: String, Codable {
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
            description: "Rotes achteckiges Schild mit 'STOP'"
        )
    }
}
