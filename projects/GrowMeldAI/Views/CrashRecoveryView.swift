import SwiftUI
import Foundation

// MARK: - Supporting Types

struct CrashEvent {
    let context: CrashContext
    let learnerState: LearnerState
}

enum CrashContext {
    case questionValidation(QuestionValidationContext)
    case examCrash(ExamState)
    case dataIntegrityIssue(DataIntegrityDetails)
    case unknown
}

struct QuestionValidationContext {
    let questionID: String
    let category: String
}

struct ExamState {
    let questionsAnswered: Int
    let totalQuestions: Int
}

struct DataIntegrityDetails {
    let issueType: String
}

struct LearnerState {
    let currentStreak: Int
}

// MARK: - QuestionService

class QuestionService {
    static let shared = QuestionService()
    init() {}
}

// MARK: - RecoveryPathIndicator

struct RecoveryPathIndicator: View {
    let streak: Int
    let suggestedCategory: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Streak: \(streak)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text("Empfohlene Kategorie: \(suggestedCategory)")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - CrashRecoveryViewModel

@MainActor
final class CrashRecoveryViewModel: ObservableObject {
    let recoveryMessage: String
    let currentStreak: Int
    let suggestedCategory: String

    private let crashEvent: CrashEvent
    private let questionService: QuestionService

    init(crashEvent: CrashEvent, questionService: QuestionService) {
        self.crashEvent = crashEvent
        self.questionService = questionService

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

    func resumeLearning() {}

    func reviewCategory() {}
}

// MARK: - CrashRecoveryView

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

            Text(viewModel.recoveryMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

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