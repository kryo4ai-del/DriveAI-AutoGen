// Services/LocalProgressService.swift
import Foundation

final class LocalProgressService: UserProgressServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let userProgress = "userProgress"
    }

    func getUserProgress() async -> UserProgress {
        guard let data = userDefaults.data(forKey: Keys.userProgress) else {
            return createDefaultProgress()
        }

        do {
            return try decoder.decode(UserProgress.self, from: data)
        } catch {
            print("Failed to decode user progress: \(error)")
            return createDefaultProgress()
        }
    }

    func saveProgress(_ progress: UserProgress) async throws {
        do {
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: Keys.userProgress)
        } catch {
            throw error
        }
    }

    func updateCategoryProgress(_ categoryId: UUID, correct: Int, total: Int) async throws {
        var progress = await getUserProgress()

        if let index = progress.categoriesProgress.firstIndex(where: { $0.categoryId == categoryId }) {
            var categoryProgress = progress.categoriesProgress[index]
            categoryProgress.answeredQuestions += total
            categoryProgress.correctAnswers += correct
            categoryProgress.accuracyPercentage = total > 0 ? (correct * 100 / total) : 0
            categoryProgress.lastPracticedDate = Date()
            categoryProgress.nextReviewDate = calculateNextReviewDate(
                accuracy: categoryProgress.accuracyPercentage,
                lastReviewDate: categoryProgress.lastPracticedDate ?? Date()
            )

            progress.categoriesProgress[index] = categoryProgress
            progress.totalCorrect += correct
            progress.totalAnswered += total

            try await saveProgress(progress)
        }
    }

    func deleteAllUserData() async throws {
        userDefaults.removeObject(forKey: Keys.userProgress)
    }

    // MARK: - Private Helpers

    private func createDefaultProgress() -> UserProgress {
        let examDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return UserProgress(
            userId: UUID(),
            examDate: examDate,
            categoriesProgress: [],
            totalCorrect: 0,
            totalAnswered: 0,
            currentStreak: 0
        )
    }

    private func calculateNextReviewDate(accuracy: Int, lastReviewDate: Date) -> Date {
        let calendar = Calendar.current
        let components: DateComponents

        switch accuracy {
        case 0..<50:
            components = DateComponents(day: 1)
        case 50..<75:
            components = DateComponents(day: 3)
        case 75..<90:
            components = DateComponents(day: 7)
        default:
            components = DateComponents(day: 14)
        }

        return calendar.date(byAdding: components, to: lastReviewDate) ?? lastReviewDate
    }
}