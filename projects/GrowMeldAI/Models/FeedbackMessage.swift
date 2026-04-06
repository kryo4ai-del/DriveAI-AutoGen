// Services/FeedbackService.swift
import Foundation

struct FeedbackMessage: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
    let category: Category
    let shouldAnnounce: Bool
    
    enum Category {
        case encouragement
        case achievement
        case milestone
        case warning
    }
}

@MainActor
class FeedbackService {
    
}