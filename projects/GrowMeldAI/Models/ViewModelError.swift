// Core/MVVM/BaseViewModel.swift
protocol ViewModelError: LocalizedError {
    var retryAction: (() -> Void)? { get }
}

@MainActor
// Enables consistent error UI across all features
class BaseViewModel: ObservableObject {
}