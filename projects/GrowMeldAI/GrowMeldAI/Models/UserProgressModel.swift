@Model
final class UserProgressModel {
    @Attribute(.unique) var categoryID: String
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var lastReviewedDate: Date?
    var reviewCount: Int = 0
}