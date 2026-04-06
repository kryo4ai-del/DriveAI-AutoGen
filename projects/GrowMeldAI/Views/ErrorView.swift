// DriveAI/Views/Questions/ErrorView.swift
import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text("Fehler")
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Erneut versuchen", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}