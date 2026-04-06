// MARK: - FeedbackButton.swift
import SwiftUI

struct FeedbackButton: View {
    @EnvironmentObject var feedbackService: FeedbackService
    @State private var showSheet = false

    var body: some View {
        Button(action: { showSheet = true }) {
            Label("Feedback", systemImage: "bubble.left.fill")
                .symbolRenderingMode(.multicolor)
        }
        .sheet(isPresented: $showSheet) {
            FeedbackBottomSheetView(
                viewModel: FeedbackBottomSheetVM(feedbackService: feedbackService)
            )
        }
        .overlay(alignment: .topTrailing) {
            if feedbackService.pendingFeedbackCount > 0 {
                Badge(count: feedbackService.pendingFeedbackCount)
                    .offset(x: 8, y: -8)
            }
        }
    }
}
