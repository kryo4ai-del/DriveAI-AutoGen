import SwiftUI

struct ActionButtonGroup: View {
    let result: SimulationResult
    var onRetry: () -> Void = {}
    var onDrillWeaknesses: () -> Void = {}
    var onReviewTopics: () -> Void = {}
    var onContinue: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 12) {
            if result.isPassed {
                Button(action: onDrillWeaknesses) {
                    Label("Improve Weak Areas", systemImage: "target.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button(action: onContinue) {
                    Label("Continue Learning", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.filled)
            } else {
                Button(action: onRetry) {
                    Label("Retry Test", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.filled)
                .tint(.red)
                
                Button(action: onReviewTopics) {
                    Label("Review Topics", systemImage: "book.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                Button(action: onContinue) {
                    Label("Back to Menu", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
}