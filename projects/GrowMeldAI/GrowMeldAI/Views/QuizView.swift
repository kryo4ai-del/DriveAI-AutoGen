// Core/ViewModels/Base/BaseViewModel.swift
import Foundation
import Combine

@MainActor

// Structured error type for views
struct ViewError: Identifiable {
    let id = UUID()
    let message: String
    let isRetryable: Bool
    
    init(_ error: Error) {
        self.message = error.localizedDescription
        self.isRetryable = (error as? RetryableError)?.isRetryable ?? false
    }
    
    init(_ message: String, isRetryable: Bool = true) {
        self.message = message
        self.isRetryable = isRetryable
    }
}

protocol RetryableError: Error {
    var isRetryable: Bool { get }
}

// Usage in ViewModel:
@MainActor

// Usage in View with error alert:
struct QuizView: View {
    let category: Any
    let viewModel: Any

    @StateObject var viewModel: QuizSessionViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                QuestionContent(viewModel: viewModel)
            }
        }
        .alert("Fehler", isPresented: .constant(viewModel.error != nil)) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
            
            if viewModel.error?.isRetryable ?? false {
                Button("Erneut versuchen") {
                    Task { await viewModel.loadQuiz() }
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.message)
            }
        }
    }
}