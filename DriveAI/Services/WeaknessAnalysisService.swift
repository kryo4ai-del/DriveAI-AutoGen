import Foundation

class WeaknessAnalysisService {

    // Keyword groups for category detection (when no explicit category field exists)
    private let categoryKeywords: [(name: String, keywords: [String])] = [
        ("Right of Way",    ["vorfahrt", "right of way", "yield", "priority", "vorrang"]),
        ("Traffic Signs",   ["sign", "schild", "zeichen", "signal", "marking", "markierung"]),
        ("Turning",         ["turn", "biegen", "abbiegen", "wenden", "u-turn", "kreuzung"]),
        ("Speed Limits",    ["speed", "geschwindigkeit", "tempo", "limit", "kmh", "km/h"]),
        ("Overtaking",      ["overtake", "überholen", "passing", "vorbeifahren"]),
        ("Parking",         ["park", "halten", "stopping", "standstreifen", "halteverbot"]),
        ("Motorway",        ["autobahn", "motorway", "highway", "freeway"]),
        ("Distance",        ["distance", "abstand", "following", "sicherheitsabstand"]),
        ("Alcohol / Drugs", ["alcohol", "alkohol", "drugs", "promille", "fahrtüchtig"]),
        ("Emergency",       ["emergency", "notfall", "first aid", "erste hilfe", "rettung"]),
    ]

    // MARK: - Analyze

    func analyzeWeaknessPatterns(from entries: [QuestionHistoryEntry]) -> [WeaknessCategory] {
        guard !entries.isEmpty else { return [] }

        // Tally attempts and incorrect counts per category
        var totals:    [String: Int] = [:]
        var incorrect: [String: Int] = [:]

        for entry in entries {
            let category = detectCategory(for: entry.questionText)
            totals[category, default: 0] += 1
            if !entry.isCorrect {
                incorrect[category, default: 0] += 1
            }
        }

        let categories = totals.map { name, total in
            WeaknessCategory(
                categoryName: name,
                incorrectCount: incorrect[name, default: 0],
                totalAttempts: total
            )
        }

        // Sort by accuracy ascending (weakest first), then by total attempts descending
        return categories.sorted {
            if $0.accuracy != $1.accuracy { return $0.accuracy < $1.accuracy }
            return $0.totalAttempts > $1.totalAttempts
        }
    }

    // Top N weakest categories with at least one incorrect answer
    func topWeakCategories(from entries: [QuestionHistoryEntry], limit: Int = 3) -> [WeaknessCategory] {
        analyzeWeaknessPatterns(from: entries)
            .filter { $0.incorrectCount > 0 }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Category detection

    private func detectCategory(for text: String) -> String {
        let lower = text.lowercased()
        for group in categoryKeywords {
            if group.keywords.contains(where: { lower.contains($0) }) {
                return group.name
            }
        }
        return "General"
    }
}
