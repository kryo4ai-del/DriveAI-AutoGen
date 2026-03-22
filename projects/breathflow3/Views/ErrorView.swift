// Views/ErrorView.swift
import SwiftUI

struct ErrorView: View {
    let error: AppError
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundColor(.red)

            Text("Unable to Load")
                .font(.headline)

            Text(error.errorDescription ?? "Unknown error")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}
