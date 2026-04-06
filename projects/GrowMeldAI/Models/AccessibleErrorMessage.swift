@MainActor
func loadDashboard() async {
    isLoading = true
    errorMessage = nil
    
    do {
        // ... load data ...
    } catch let error as LocalDataError {
        let accessibleError = AccessibleErrorMessage(
            shortMessage: "Fehler beim Laden",
            longDescription: error.voiceOverDescription,
            recoveryAction: error.recoveryAction
        )
        errorMessage = accessibleError.shortMessage
        analyticsService.logError("dashboard_error", details: error)
    } catch {
        errorMessage = "Ein unbekannter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut."
    }
}

struct AccessibleErrorMessage {
    let shortMessage: String
    let longDescription: String
    let recoveryAction: () -> Void
}

extension LocalDataError {
    var voiceOverDescription: String {
        switch self {
        case .databaseOpenFailed:
            return "Die Datenbank konnte nicht geöffnet werden. Überprüfen Sie Ihren Speicherplatz."
        case .userNotFound:
            return "Benutzerkonto nicht gefunden. Bitte führen Sie das Onboarding erneut durch."
        default:
            return "Ein Datenbankfehler ist aufgetreten."
        }
    }
    
    var recoveryAction: (() -> Void)? {
        switch self {
        case .userNotFound:
            return { OnboardingCoordinator.restart() }
        default:
            return nil
        }
    }
}