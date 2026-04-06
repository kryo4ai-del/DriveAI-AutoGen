// FahrschulFokusTrackerModel.swift
import Foundation

struct ExamTopic: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: Difficulty
    let category: TopicCategory
    let masteryLevel: MasteryLevel

    enum Difficulty: String, Codable {
        case beginner, intermediate, advanced
    }

    enum TopicCategory: String, Codable {
        case trafficSigns = "Verkehrszeichen"
        case rightOfWay = "Vorfahrt"
        case speedLimits = "Geschwindigkeitsbegrenzungen"
        case parking = "Parken"
        case environmentalZone = "Umweltzone"
        case pedestrianCrossing = "Fußgängerüberweg"
    }

    enum MasteryLevel: String, Codable {
        case notStarted = "Nicht begonnen"
        case inProgress = "In Arbeit"
        case reviewed = "Wiederholt"
        case mastered = "Beherrscht"
    }
}

struct FahrschulFokusTrackerModel {
    var topics: [ExamTopic]
    var totalTopics: Int { topics.count }
    var completedTopics: Int { topics.filter { $0.masteryLevel == .mastered }.count }
    var completionPercentage: Double { Double(completedTopics) / Double(totalTopics) }

    init(topics: [ExamTopic] = Self.defaultTopics) {
        self.topics = topics
    }

    static var defaultTopics: [ExamTopic] {
        [
            ExamTopic(id: UUID(), title: "Vorfahrt gewähren", description: "Regeln an Kreuzungen ohne Schilder", difficulty: .beginner, category: .rightOfWay, masteryLevel: .notStarted),
            ExamTopic(id: UUID(), title: "Stoppschild", description: "Haltelinie und Vorfahrtsregelung", difficulty: .beginner, category: .trafficSigns, masteryLevel: .notStarted),
            ExamTopic(id: UUID(), title: "30 km/h Zone", description: "Tempo 30 Bereiche und Ausnahmen", difficulty: .intermediate, category: .speedLimits, masteryLevel: .notStarted),
            ExamTopic(id: UUID(), title: "Parken auf Gehwegen", description: "Erlaubte und verbotene Parkpositionen", difficulty: .intermediate, category: .parking, masteryLevel: .notStarted),
            ExamTopic(id: UUID(), title: "Umweltplakette", description: "Kennzeichnung und Zonen in Städten", difficulty: .advanced, category: .environmentalZone, masteryLevel: .notStarted),
            ExamTopic(id: UUID(), title: "Fußgängerüberweg", description: "Verhalten und Vorfahrtsregeln", difficulty: .beginner, category: .pedestrianCrossing, masteryLevel: .notStarted)
        ]
    }
}