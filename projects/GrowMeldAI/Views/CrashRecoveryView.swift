// Sources/Views/ErrorStates/CrashRecoveryView.swift
import SwiftUI

/// Recovery screen after a crash with competence reinforcement
struct CrashRecoveryView: View {
    @StateObject var viewModel: CrashRecoveryViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Oops! Ein Problem ist aufgetreten")
                .font(.title)
                .fontWeight(.bold)

            if let message = viewModel.recoveryMessage {
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            RecoveryPathIndicator(
                streak: viewModel.currentStreak,
                suggestedCategory: viewModel.suggestedCategory
            )

            VStack(spacing: 16) {
                Button(action: viewModel.resumeLearning) {
                    Text("Weiterlernen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: viewModel.reviewCategory) {
                    Text("Kategorie wiederholen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

/// ViewModel for the recovery screen
@MainActor
final class CrashRecoveryViewModel: ObservableObject {
    let recoveryMessage: String
    let currentStreak: Int
    let suggestedCategory: String

    private let crashEvent: CrashEvent
    private let questionService: QuestionService

    init(
        crashEvent: CrashEvent,
        questionService: QuestionService
    ) {
        self.crashEvent = crashEvent
        self.questionService = questionService

        // Generate recovery message based on crash context
        switch crashEvent.context {
        case .questionValidation(let context):
            self.recoveryMessage = "Dieser Fehler trat bei Frage \(context.questionID) in der Kategorie '\(context.category)' auf. Lass uns diese Kategorie gezielt wiederholen, um ähnliche Fehler zu vermeiden."
            self.currentStreak = crashEvent.learnerState.currentStreak
            self.suggestedCategory = context.category

        case .examCrash(let examState):
            self.recoveryMessage = "Dein Exam ist bei Frage \(examState.questionsAnswered) von \(examState.totalQuestions) abgebrochen. Wir setzen dort fort, wo du aufgehört hast."
            self.currentStreak = crashEvent.learnerState.currentStreak
            self.suggestedCategory = "Examensvorbereitung"

        case .dataIntegrityIssue(let details):
            self.recoveryMessage = "Ein technisches Problem wurde erkannt (\(details.issueType)). Wir empfehlen, die App neu zu starten."
            self.currentStreak = 0
            self.suggestedCategory = "Technische Probleme"

        case .unknown:
            self.recoveryMessage = "Ein unerwartetes Problem ist aufgetreten. Bitte starte die App neu."
            self.currentStreak = 0
            self.suggestedCategory = "Allgemein"
        }
    }

    func resumeLearning() {
        // Resume from last known state
    }

    func reviewCategory() {
        // Navigate to category review
    }
}