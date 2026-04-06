// ViewModels/Shared/FeedbackManager.swift
import UIKit
@MainActor
final class FeedbackManager {
    static let shared = FeedbackManager()
    
    func provideFeedback(isCorrect: Bool) {
        let feedback = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .light)
        feedback.impactOccurred()
    }
    
    func announceResult(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}