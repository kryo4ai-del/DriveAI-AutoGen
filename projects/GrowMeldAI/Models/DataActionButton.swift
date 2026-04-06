import SwiftUI

struct DataActionButton: View {
    let icon: String
    let title: String
    let description: String
    var isDangerous = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDangerous ? .red : .blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isDangerous ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(description)
        .accessibilityHint(isDangerous
            ? "Warnung: Aktion ist permanent und kann nicht rückgängig gemacht werden. Doppelt tippen zum Bestätigen."
            : "Doppelt tippen, um \(title.lowercased()) zu starten")
        .accessibilityAddTraits(.isButton)
    }
}