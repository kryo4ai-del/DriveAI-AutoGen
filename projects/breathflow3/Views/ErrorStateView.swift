// Views/ErrorStateView.swift
import SwiftUI

struct ErrorStateView: View {
    let error: ExerciseSelectionError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Something Went Wrong")
                .font(.headline)

            Text(error.errorDescription ?? "Unknown error")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("Try Again")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .frame(minHeight: 44)
        }
        .padding(32)
        .accessibilityLabel("Error loading exercises")
        .accessibilityValue(error.errorDescription ?? "Unknown")
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.dash")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No Exercises Found")
                .font(.headline)

            Text("Try adjusting your filters to see more options")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .accessibilityLabel("No exercises available with current filters")
    }
}
