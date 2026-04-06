import SwiftUI

struct PlanEmptyStateView: View {
    let onStartAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "road.lanes")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("Dein Lernplan wird dich sicher durch die Prüfung bringen")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("Gib dein Prüfungsdatum ein und starte jetzt mit gezieltem Lernen")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onStartAction) {
                Text("Prüfungsdatum festlegen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}