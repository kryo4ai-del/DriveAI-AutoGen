import SwiftUI

struct LearningPlanEmptyView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("Dein Lernplan startet morgen — heute übst du frei!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Wir erstellen deinen persönlichen Plan basierend auf deinen Fortschritten. Starte einfach mit Übungsfragen!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onStart) {
                Text("Jetzt üben")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding()
    }
}