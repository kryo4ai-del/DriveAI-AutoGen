import Foundation
struct CategoryStat: Sendable {
    let categoryID: UUID
    let categoryName: String
    let correctCount: Int
    let totalAttempts: Int
}
