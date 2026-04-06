import Foundation

struct PerformanceSnapshot: Codable, Equatable {
    let examReadiness: Double
    let overallMastery: Double
    let weakAreas: [WeakArea]
    let examSessions: [ExamSession]
    let lastUpdated: Date

    var readinessNarrative: String {
        let percentage = Int(examReadiness * 100)

        if percentage >= 85 {
            return "🎉 Du bist bereit! Starte die Theorieprüfung mit Zuversicht."
        } else if percentage >= 70 {
            let remaining = Int(ceil((85.0 - examReadiness) / 0.05))
            return "📈 Du bist bei \(percentage)% — mit \(remaining) gezielten Übungen erreichst du 85%!"
        } else {
            let neededSessions = Int(ceil((85.0 - examReadiness) / 0.10))
            return "🚦 Du bist bei \(percentage)%. Starte \(neededSessions) Übungssitzungen in deinen schwächsten Themen."
        }
    }

    var masteryNarrative: String {
        let percentage = Int(overallMastery * 100)

        if percentage >= 85 {
            return "🏆 Hervorragend! Du beherrschst die meisten Themen."
        } else if percentage >= 70 {
            return "📚 Gute Fortschritte! Konzentriere dich auf \(weakAreas.count) schwache Themen."
        } else {
            return "🎯 Du hast noch \(85 - percentage)% bis zum Ziel. Jede Übung bringt dich näher!"
        }
    }
}