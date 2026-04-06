// ErrorHandling.swift
import Foundation
import SwiftUI

/// Centralized error handling for DriveAI app
enum DriveAIError: Error, LocalizedError {
    case dataLoadingFailed
    case invalidUserInput
    case networkUnavailable
    case categoryNotFound
    case questionNotFound
    case userDataCorrupted
    case examDateNotSet

    var errorDescription: String? {
        switch self {
        case .dataLoadingFailed:
            return String(localized: "Failed to load required data. Please check your internet connection.", comment: "Error description for data loading failure")
        case .invalidUserInput:
            return String(localized: "The input you provided is invalid. Please try again.", comment: "Error description for invalid user input")
        case .networkUnavailable:
            return String(localized: "No internet connection available. Please connect to Wi-Fi or mobile data.", comment: "Error description for network issues")
        case .categoryNotFound:
            return String(localized: "The requested category could not be found.", comment: "Error description for missing category")
        case .questionNotFound:
            return String(localized: "The requested question could not be found.", comment: "Error description for missing question")
        case .userDataCorrupted:
            return String(localized: "Your user data appears to be corrupted. Please reinstall the app.", comment: "Error description for corrupted user data")
        case .examDateNotSet:
            return String(localized: "Your exam date is not set. Please set your exam date in settings.", comment: "Error description for missing exam date")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dataLoadingFailed:
            return String(localized: "Restart the app or check your internet connection.", comment: "Recovery suggestion for data loading failure")
        case .invalidUserInput:
            return String(localized: "Make sure you're entering valid information.", comment: "Recovery suggestion for invalid input")
        case .networkUnavailable:
            return String(localized: "Enable airplane mode and disable it again to reset your network connection.", comment: "Recovery suggestion for network issues")
        case .categoryNotFound, .questionNotFound:
            return String(localized: "Try selecting a different category or question.", comment: "Recovery suggestion for missing content")
        case .userDataCorrupted:
            return String(localized: "Back up your data if possible, then reinstall the app.", comment: "Recovery suggestion for corrupted data")
        case .examDateNotSet:
            return String(localized: "Go to Settings > Exam Date to set your exam date.", comment: "Recovery suggestion for missing exam date")
        }
    }
}

/// Error handling utility functions
enum ErrorHandler {
    static func handle(_ error: Error, in viewContext: String) {
        let nsError = error as NSError

        if let driveAIError = error as? DriveAIError {
            print("DriveAI Error in \(viewContext): \(driveAIError.errorDescription ?? "Unknown error")")
            print("Recovery suggestion: \(driveAIError.recoverySuggestion ?? "No suggestion")")
        } else {
            print("Unexpected error in \(viewContext): \(nsError.localizedDescription)")
        }

        // In production, you might want to log this to a crash reporting service
        #if DEBUG
        print("Full error details: \(error)")
        #endif
    }

    static func presentableError(from error: Error) -> String {
        if let driveAIError = error as? DriveAIError {
            return driveAIError.errorDescription ?? "Unknown error occurred"
        }
        return error.localizedDescription
    }
}