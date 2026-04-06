// Core/MVVM/BaseViewModel.swift
protocol ViewModelError: LocalizedError {
    var retryAction: (() -> Void)? { get }
}

// Enables consistent error UI across all features
@MainActor
class BaseViewModel: ObservableObject {
}