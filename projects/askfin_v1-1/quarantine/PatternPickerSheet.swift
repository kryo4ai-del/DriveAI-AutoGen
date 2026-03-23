import SwiftUI

struct PatternPickerSheet: View {

    let selectedPattern: BreathPattern
    let onSelect: (BreathPattern) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(BreathPattern.all) { pattern in
                PatternPickerRow(
                    pattern: pattern,
                    isSelected: pattern.id == selectedPattern.id
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(pattern)
                    dismiss()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Übung wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct PatternPickerRow: View {

    let pattern: BreathPattern
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: pattern.patternIcon)
                .font(.title3)
                .foregroundStyle(pattern.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(pattern.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(pattern.phaseBreakdownLabel) · \(pattern.estimatedDurationLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                Text(pattern.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(pattern.accentColor)
            }
        }
        .padding(.vertical, 4)
    }
}