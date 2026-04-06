import Foundation

/// Unlockable achievements tied to learning progress
struct GrowthMilestone: Codable, Sendable, Identifiable {
    let id: UUID
    let type: MilestoneType
    let unlockedDate: Date
    let reward: MilestoneReward
    let description: String
    let emoji: String
    
    static func create(type: MilestoneType) -> GrowthMilestone {
        let (desc, emoji, reward) = type.details
        return GrowthMilestone(
            id: UUID(),
            type: type,
            unlockedDate: Date(),
            reward: reward,
            description: desc,
            emoji: emoji
        )
    }
}

enum MilestoneType: String, Codable, Sendable {
    case questionsMilestone50 = "q50"
    case questionsMilestone100 = "q100"
    case questionsMilestone250 = "q250"
    case questionsMilestone500 = "q500"
    case streakDay3 = "streak3"
    case streakDay7 = "streak7"
    case streakDay14 = "streak14"
    case categoryMastery = "category_master"
    case speedDemon = "speed_demon"
    case perfectDay = "perfect_day"
    case examReady = "exam_ready"
    case weeklyChampion = "weekly_champion"
    
    var details: (description: String, emoji: String, reward: MilestoneReward) {
        switch self {
        case .questionsMilestone50:
            return ("50 Fragen beantwortet", "🎯", .init(points: 50, xpMultiplier: 1.0))
        case .questionsMilestone100:
            return ("100 Fragen beantwortet", "💯", .init(points: 100, xpMultiplier: 1.1))
        case .questionsMilestone250:
            return ("250 Fragen beantwortet", "🏆", .init(points: 250, xpMultiplier: 1.2))
        case .questionsMilestone500:
            return ("500 Fragen beantwortet", "👑", .init(points: 500, xpMultiplier: 1.5))
        case .streakDay3:
            return ("3 Tage Serie!", "🔥", .init(points: 30, xpMultiplier: 1.1))
        case .streakDay7:
            return ("7 Tage Serie! 🚀", "🔥", .init(points: 70, xpMultiplier: 1.3))
        case .streakDay14:
            return ("14 Tage Serie! Du bist im Flow!", "🔥", .init(points: 140, xpMultiplier: 1.5))
        case .categoryMastery:
            return ("Kategorie gemeistert (95%+)", "🎓", .init(points: 100, xpMultiplier: 1.2))
        case .speedDemon:
            return ("Speed Demon: 10 Fragen in <5 min", "⚡", .init(points: 75, xpMultiplier: 1.1))
        case .perfectDay:
            return ("Perfekter Tag: 0 Fehler in 24h", "✨", .init(points: 150, xpMultiplier: 1.4))
        case .examReady:
            return ("Du bist bereit für die Prüfung!", "✅", .init(points: 500, xpMultiplier: 2.0))
        case .weeklyChampion:
            return ("Diese Woche: Die meisten Fragen!", "🥇", .init(points: 120, xpMultiplier: 1.2))
        }
    }
}

struct MilestoneReward: Codable, Sendable {
    let points: Int
    let xpMultiplier: Double
}