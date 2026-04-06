// MARK: - FeedbackBottomSheetVM.swift
import Foundation
import Combine

final class FeedbackBottomSheetVM: ObservableObject {
    @Published var selectedCategory: FeedbackCategory = .other
    @Published var message: String = ""
    @Published var isSubmitting: Bool = false
    @Published var showSuccess: Bool = false
    @Published var error: FeedbackError?

    private let feedbackService: FeedbackService
    private var cancellables = Set<AnyCancellable>()

    init(feedbackService: FeedbackService) {
        self.feedbackService = feedbackService
    }

    @MainActor
    func submitFeedback() async {
        isSubmitting = true
        error = nil

        do {
            try await feedbackService.submitFeedback(
                category: selectedCategory,
                message: message
            )

            // Emotional hook: Connect feedback to user's exam journey
            showSuccess = true

            // Auto-dismiss after 3 seconds
            try await Task.sleep(nanoseconds: 3_000_000_000)
            showSuccess = false

            // Clear form
            message = ""
            selectedCategory = .other

        } catch let error as FeedbackError {
            self.error = error
        } catch {
            self.error = .saveFailed(underlying: error)
        }

        isSubmitting = false
    }

    func validateMessage() -> Bool {
        do {
            try UserFeedback.validate(message: message)
            return true
        } catch {
            self.error = error as? FeedbackError ?? .invalidMessage(reason: error.localizedDescription)
            return false
        }
    }
}