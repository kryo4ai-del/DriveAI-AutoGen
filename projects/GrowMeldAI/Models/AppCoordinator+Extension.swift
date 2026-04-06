import Foundation
import SwiftUI

// MARK: - AppCoordinator Extension

extension AppCoordinator {

    // MARK: - Convenience Navigation

    func showExam() {
        navigate(to: .exam)
    }

    func showSettings() {
        navigate(to: .settings)
    }

    func showProgress() {
        navigate(to: .progress)
    }

    func showOnboarding() {
        navigate(to: .onboarding)
    }

    func showHome() {
        navigateToRoot()
    }

    // MARK: - Exam Result Convenience

    func showExamResult(_ result: GrowMeldExamResult) {
        navigate(to: .examResult(result))
    }

    // MARK: - Statistics

    func averageScore() -> Double {
        let results = loadStoredExamResults()
        guard !results.isEmpty else { return 0 }
        let total = results.reduce(0.0) { $0 + $1.percentageScore }
        return total / Double(results.count)
    }

    func passedExamsCount() -> Int {
        loadStoredExamResults().filter { $0.passed }.count
    }

    func totalExamsCount() -> Int {
        loadStoredExamResults().count
    }

    func recentResults(limit: Int = 5) -> [GrowMeldExamResult] {
        let results = loadStoredExamResults()
            .sorted { $0.date > $1.date }
        return Array(results.prefix(limit))
    }
}