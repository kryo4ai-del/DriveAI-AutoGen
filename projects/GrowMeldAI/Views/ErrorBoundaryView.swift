// MARK: - ErrorBoundaryView.swift
import SwiftUI

struct ErrorBoundaryView<Content: View>: View {
    @StateObject private var viewModel = ErrorBoundaryViewModel()
    let content: () -> Content

    var body: some View {
        Group {
            if viewModel.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Ein Fehler ist aufgetreten")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(viewModel.errorMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Erneut versuchen") {
                        viewModel.reset()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                content()
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        viewModel.reset()
                    }
            }
        }
    }
}