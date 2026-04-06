@Published var error: FeedbackSubmissionError?

enum FeedbackSubmissionError: LocalizedError {
    case networkUnavailable
    case databaseError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Keine Verbindung — wird später gespeichert"
        case .databaseError:
            return "Fehler beim Speichern"
        case .unknown:
            return "Unbekannter Fehler"
        }
    }
}

func submitFeedback() async {
    isSubmitting = true
    defer { isSubmitting = false }
    
    do {
        try await feedbackService.saveFeedback(feedback)
        confirmationMessage = "Deine Notiz gespeichert — diese Frage wird in 3 Tagen wiederholt."
        error = nil
    } catch let networkError as URLError where networkError.code == .notConnectedToInternet {
        error = .networkUnavailable
        confirmationMessage = nil
    } catch {
        error = .databaseError
        confirmationMessage = nil
    }
}

// In View:
if let error = viewModel.error {
    HStack {
        Image(systemName: "exclamationmark.circle.fill")
            .foregroundColor(.red)
        Text(error.errorDescription ?? "Fehler")
    }
    .padding()
    .background(Color.red.opacity(0.1))
    .cornerRadius(8)
}