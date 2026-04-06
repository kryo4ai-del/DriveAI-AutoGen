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

@MainActor
final class NotificationConsentViewModel: ObservableObject {
    // ... existing code ...
    
    func acceptConsent() async {
        isLoading = true
        defer { isLoading = false }
        
        let granted = await pushNotificationService.requestPermission()
        guard granted else {
            consentState = .permissionDenied
            errorMessage = "Benachrichtigungen konnten nicht aktiviert werden"
            logPermissionDenied()
            return
        }
        
        consentState = .accepted
        await persistenceService.updatePreference(
            state: .accepted,
            acceptedAt: Date(),
            declinedAt: nil,
            nextRetryDate: nil
        )
        
        // ✅ Collect errors but continue scheduling
        var schedulingErrors: [NotificationSchedulingError] = []
        
        do {
            try await pushNotificationService.scheduleTestNotification()
            logSchedulingSuccess(type: "test")
        } catch {
            schedulingErrors.append(.testNotification(error))
            logSchedulingFailure(type: "test", error: error)
        }
        
        do {
            try await pushNotificationService.scheduleExamCountdownReminders(for: examDate)
            logSchedulingSuccess(type: "examCountdown")
        } catch {
            schedulingErrors.append(.examCountdown(error))
            logSchedulingFailure(type: "examCountdown", error: error)
        }
        
        do {
            try await pushNotificationService.scheduleDailyLearningTips()
            logSchedulingSuccess(type: "dailyTips")
        } catch {
            schedulingErrors.append(.dailyTips(error))
            logSchedulingFailure(type: "dailyTips", error: error)
        }
        
        // ✅ Report overall status
        if schedulingErrors.isEmpty {
            logConsentAccepted(status: "full_success")
        } else if schedulingErrors.count < 3 {
            let error = schedulingErrors.count == 1 ? schedulingErrors[0] : .multipleErrors(schedulingErrors)
            errorMessage = error.errorDescription
            logConsentAccepted(status: "partial_success", failedTypes: schedulingErrors.map { "\($0)" })
        } else {
            errorMessage = "Alle Benachrichtigungen konnten nicht aktiviert werden"
            logConsentAccepted(status: "full_failure")
        }
        
        shouldShowConsentFlow = false
    }
    
    private func logSchedulingSuccess(type: String) {
        analyticsService.log(
            event: "notification_scheduled",
            parameters: ["type": type, "status": "success"]
        )
    }
    
    private func logSchedulingFailure(type: String, error: Error) {
        analyticsService.log(
            event: "notification_scheduled",
            parameters: [
                "type": type,
                "status": "failure",
                "error": error.localizedDescription
            ]
        )
    }
    
    private func logConsentAccepted(status: String, failedTypes: [String] = []) {
        analyticsService.log(
            event: "consent_accepted",
            parameters: [
                "status": status,
                "failed_types": failedTypes.joined(separator: ","),
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
    }
}