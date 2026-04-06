import SwiftUI
struct NavigationButtonsView: View {
    let onNext: () -> Void
    let isAnswered: Bool
    let questionNumber: Int
    let totalQuestions: Int
    
    var body: some View {
        HStack {
            Button(action: { /* previous */ }) {
                Text("Zurück")
            }
            .disabled(questionNumber == 1)
            .accessibilityLabel(Text("Vorherige Frage"))
            .accessibilityHint(Text("Zur Frage \(questionNumber - 1) gehen"))
            
            Spacer()
            
            Button(action: onNext) {
                Text("Weiter")
            }
            .disabled(!isAnswered)
            .accessibilityLabel(Text("Nächste Frage"))
            .accessibilityValue(
                Text(questionNumber == totalQuestions 
                    ? "Letzte Frage" 
                    : "Frage \(questionNumber + 1) von \(totalQuestions)")
            )
            .accessibilityHint(Text(
                isAnswered 
                    ? "Doppeltippen, um zur nächsten Frage zu gehen" 
                    : "Beantworte erst die aktuelle Frage"
            ))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}