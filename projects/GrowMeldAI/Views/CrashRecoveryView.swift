import SwiftUI
import Foundation

struct CrashEvent {
    let errorDescription: String
    let category: String
    let streak: Int

    init(errorDescription: String = "Unbekannter Fehler", category: String = "Allgemein", streak: Int = 0) {
        self.errorDescription = errorDescription
        self.category = category
        self.streak = streak
    }
}

struct RecoveryPathIndicator: View {
    let streak: Int
    let suggestedCategory: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
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

@MainActor
final class CrashRecoveryViewModel: ObservableObject {
    let recoveryMessage: String
    let currentStreak: Int
    let suggestedCategory: String

    private let crashEvent: CrashEvent

    init(crashEvent: CrashEvent) {
        self.crashEvent = crashEvent
        self.recoveryMessage = "Ein Fehler ist aufgetreten: \(crashEvent.errorDescription). Lass uns die Kategorie '\(crashEvent.category)' gezielt wiederholen."
        self.currentStreak = crashEvent.streak
        self.suggestedCategory = crashEvent.category
    }

    func resumeLearning() {
    }

    func reviewCategory() {
    }
}