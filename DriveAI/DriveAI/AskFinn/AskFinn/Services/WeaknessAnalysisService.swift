import Foundation

class WeaknessAnalysisService {

    // MARK: - Analyze

    func analyzeWeaknessPatterns(from entries: [QuestionHistoryEntry]) -> [WeaknessCategory] {
        guard !entries.isEmpty else { return [] }

        // Use stored QuestionCategory from each entry
        var totals:    [String: Int] = [:]
        var incorrect: [String: Int] = [:]

        for entry in entries {
            let name = entry.category.rawValue
            totals[name, default: 0] += 1
            if !entry.isCorrect {
                incorrect[name, default: 0] += 1
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
}
