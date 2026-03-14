import Foundation

/// A single answer choice. Each option owns exactly one SwipeDirection.
struct AnswerOption: Identifiable, Equatable {
    let id: UUID
    let text: String
    let swipeDirection: SwipeDirection

    init(text: String, swipeDirection: SwipeDirection) {
        self.id = UUID()
        self.text = text
        self.swipeDirection = swipeDirection
    }
}