// ReadinessPulseScreen.swift
import SwiftUI

struct ReadinessPulseScreen: View {
    let score: Double
    let onContinue: () -> Void

    private var plantStage: String {
        switch score {
        case 0..<0.3: return "🌱 Keimling"
        case 0.3..<0.6: return "🌿 Trieb"
        case 0.6..<0.8: return "🌳 Baum"
        default: return "🌳🌳 Stark & sicher"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Deine Prüfungsreife")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(plantStage)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ProgressBar(progress: score, label: "Selbstvertrauen")
                    .frame(height: 20)

                Text(motivationalMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()

            Spacer()

            Button(action: onContinue) {
                Text("Weiter üben")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
        .navigationTitle("Prüfungsreife")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var motivationalMessage: String {
        switch score {
        case 0..<0.5:
            return "Du bist auf dem Weg! Jede Frage bringt dich näher an dein Ziel."
        case 0.5..<0.8:
            return "Gut gemacht! Du hast schon viel gelernt – jetzt fehlt nur noch die Routine."
        default:
            return "Du bist bereit! Die Theorieprüfung ist nur noch Formsache. 🎉"
        }
    }
}