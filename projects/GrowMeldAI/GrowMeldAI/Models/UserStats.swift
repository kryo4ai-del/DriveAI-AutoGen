import Foundation

struct UserStats: Codable {
    var totalQuestionsAnswered: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageScore: Double = 0.0 // 0.0...1.0
    var totalExams: Int = 0
    var passedExams: Int = 0
    var examDate: Date?
    var licenseClass: String?
    var categoriesMastered: Int = 0
    var totalCategories: Int = 0

    var progressPercentage: Double {
        guard totalCategories > 0 else { return 0.0 }
        return Double(categoriesMastered) / Double(totalCategories)
    }

    var examReadiness: ExamReadiness {
        if let examDate = examDate {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0

            if daysLeft <= 0 {
                return .now
            } else if daysLeft <= 7 {
                return .soon
            }
        }

        if averageScore >= 0.9 {
            return .excellent
        } else if averageScore >= 0.75 {
            return .good
        } else {
            return .needsWork
        }
    }
}
