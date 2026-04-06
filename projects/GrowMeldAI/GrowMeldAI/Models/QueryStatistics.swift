import Foundation

struct QueryStatistics: Equatable {
    let totalQuestions: Int
    let filteredCount: Int
    let difficultyDistribution: [Int: Int]
    let locationDistribution: [Location: Int]
    let sizeClassDistribution: [SizeClass: Int]

    init(
        totalQuestions: Int,
        filteredCount: Int,
        difficultyDistribution: [Int: Int],
        locationDistribution: [Location: Int],
        sizeClassDistribution: [SizeClass: Int]
    ) {
        self.totalQuestions = totalQuestions
        self.filteredCount = filteredCount
        self.difficultyDistribution = difficultyDistribution
        self.locationDistribution = locationDistribution
        self.sizeClassDistribution = sizeClassDistribution
    }
}