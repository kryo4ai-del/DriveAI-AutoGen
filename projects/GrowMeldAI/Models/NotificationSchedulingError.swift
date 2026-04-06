import Foundation

enum NotificationSchedulingError: LocalizedError {
    case testNotification(Error)
    case examCountdown(Error)
    case dailyTips(Error)
    case multipleErrors([Self])

    var errorDescription: String? {
        switch self {
        case .testNotification(let error):
            return "Test-Benachrichtigung fehlgeschlagen: \(error.localizedDescription)"
        case .examCountdown(let error):
            return "Exam-Countdown fehlgeschlagen: \(error.localizedDescription)"
        case .dailyTips(let error):
            return "Tägliche Tipps fehlgeschlagen: \(error.localizedDescription)"
        case .multipleErrors(let errors):
            let errorList = errors.map { $0.errorDescription ?? "Unbekannter Fehler" }.joined(separator: ", ")
            return "Mehrere Fehler: \(errorList)"
        }
    }
}

// NotificationConsentViewModel declared in ViewModels/NotificationConsentViewModel.swift
