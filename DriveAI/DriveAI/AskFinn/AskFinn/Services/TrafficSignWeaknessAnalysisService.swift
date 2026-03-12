import Foundation

class TrafficSignWeaknessAnalysisService {

    // MARK: - Analyze

    /// Groups learning-mode history entries by TrafficSignCategory and computes accuracy per category.
    func analyzeWeaknessPatterns(from entries: [TrafficSignHistoryEntry]) -> [TrafficSignWeaknessCategory] {
        // Only learning-mode entries have a meaningful correct/incorrect signal
        let learningEntries = entries.filter { $0.wasLearningMode }
        guard !learningEntries.isEmpty else { return [] }

        var totals:    [String: Int] = [:]
        var incorrect: [String: Int] = [:]

        for entry in learningEntries {
            let name = entry.signCategory.rawValue
            totals[name, default: 0] += 1
            if entry.userAnswerCorrect == false {
                incorrect[name, default: 0] += 1
            }
        }

        let categories = totals.map { name, total in
            TrafficSignWeaknessCategory(
                categoryName: name,
                incorrectCount: incorrect[name, default: 0],
                totalAttempts: total
            )
        }

        // Sort by accuracy ascending (weakest first), break ties by total descending
        return categories.sorted {
            if $0.accuracyRate != $1.accuracyRate { return $0.accuracyRate < $1.accuracyRate }
            return $0.totalAttempts > $1.totalAttempts
        }
    }

    /// Top N weakest categories with at least one incorrect answer.
    func topWeakCategories(from entries: [TrafficSignHistoryEntry], limit: Int = 3) -> [TrafficSignWeaknessCategory] {
        analyzeWeaknessPatterns(from: entries)
            .filter { $0.incorrectCount > 0 }
            .prefix(limit)
            .map { $0 }
    }
}
