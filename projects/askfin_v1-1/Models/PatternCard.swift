import SwiftUI

struct PatternCard: View {

    let pattern: BreathPattern
    let descriptionText: String
    let durationLabel: String
    var onChangeTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 0) {
                Text("Empfohlene Übung")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Ändern", action: onChangeTap)
                    .font(.subheadline)
                    .foregroundStyle(pattern.accentColor)
            }

            HStack(spacing: 12) {
                Image(systemName: pattern.patternIcon)
                    .font(.title2)
                    .foregroundStyle(pattern.accentColor)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(pattern.name)
                        .font(.headline)

                    Text(pattern.phaseBreakdownLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                Text(durationLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemFill), in: Capsule())
            }

            Text(descriptionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.2), value: pattern.id)
    }
}