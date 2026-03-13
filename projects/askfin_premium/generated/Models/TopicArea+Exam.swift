import Foundation

extension TopicArea {

    // MARK: - Official exam weights
    //
    // Maps each TopicArea to its question allocation in a 30-question exam.
    // Returns [String: Double] keyed by rawValue with fractions summing to 1.0,
    // matching SimulationConfig.topicWeights type.

    static var officialExamWeights: [String: Double] {
        let allocation: [TopicArea: Int] = [
            .rightOfWay:      3,
            .trafficSigns:    3,
            .speed:           2,
            .distance:        2,
            .overtaking:      2,
            .parking:         2,
            .turning:         2,
            .highway:         2,
            .railwayCrossing: 1,
            .visibility:      2,
            .emergency:       1,
            .alcoholDrugs:    2,
            .passengers:      1,
            .vehicleTech:     2,
            .environment:     1,
            .general:         2,
        ]
        let total = Double(allocation.values.reduce(0, +))
        return Dictionary(uniqueKeysWithValues:
            allocation.map { ($0.key.rawValue, Double($0.value) / total) }
        )
    }

    // MARK: - Fehlerpunkte categorisation
    //
    // No default case — compiler enforces handling of every TopicArea.
    // rightOfWay = Vorfahrt (5 FP, instant-fail eligible).
    // Core safety topics = Grundstoff (3 FP).
    // All others = Standard (2 FP).

    var fehlerpunkteCategory: FehlerpunkteCategory {
        switch self {
        case .rightOfWay:
            return .vorfahrt
        case .railwayCrossing, .visibility, .emergency, .alcoholDrugs:
            return .grundstoff
        case .trafficSigns, .speed, .distance, .overtaking, .parking,
             .turning, .highway, .passengers, .vehicleTech,
             .environment, .general:
            return .standard
        }
    }
}