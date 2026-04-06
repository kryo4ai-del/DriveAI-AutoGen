// MARK: - ErrorBoundaryViewModel.swift
import Foundation
import Combine
import SwiftUI

final class ErrorBoundaryViewModel: ObservableObject {
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    private var cancellables = Set<AnyCancellable>()

    func handleError(_ error: Error) {
        hasError = true
        errorMessage = error.localizedDescription
    }

    func reset() {
        hasError = false
        errorMessage = ""
    }
}