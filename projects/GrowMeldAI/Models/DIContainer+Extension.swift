import Foundation

#if DEBUG
extension DIContainer {
    static let preview = DIContainer(
        questionRepository: PreviewQuestionRepository(),
        examService: PreviewExamService(),
        userStorage: PreviewUserStorage(),
        scoringService: PreviewScoringService(),
        analyticsService: PreviewAnalyticsService()
    )
}
#endif