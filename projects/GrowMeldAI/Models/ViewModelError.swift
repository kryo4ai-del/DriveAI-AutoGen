// Core/MVVM/BaseViewModel.swift
import Foundation
protocol ViewModelError: LocalizedError {
    var retryAction: (() -> Void)? { get }
}

// Enables consistent error UI across all features
// Class BaseViewModel declared in ViewModels/BaseViewModel.swift
