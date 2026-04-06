// ToxicityWarningCardView.swift
import SwiftUI

struct ToxicityWarningCardView: View {
    let warning: ToxicityWarning

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: warning.level.systemImage)
                    .font(.title2)
                    .foregroundColor(colorForLevel(warning.level))

                VStack(alignment: .leading, spacing: 4) {
                    Text(warning.level.localizedString)
                        .font(.headline)
                        .foregroundColor(colorForLevel(warning.level))

                    Text(warning.content.localizedTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Text(warning.content.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)

            if !warning.affectedGroups.isEmpty {
                HStack {
                    Text("Betrifft:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    ForEach(warning.affectedGroups, id: \.self) { group in
                        Text(group.localizedString)
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            if !warning.content.safetyTips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sicherheitstipps:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    ForEach(warning.content.safetyTips, id: \.self) { tip in
                        Text("• \(tip)")
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColorForLevel(warning.level))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorForLevel(warning.level), lineWidth: 1)
        )
    }

    private func colorForLevel(_ level: ToxicityLevel) -> Color {
        switch level {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }

    private func backgroundColorForLevel(_ level: ToxicityLevel) -> Color {
        switch level {
        case .info: return .blue.opacity(0.1)
        case .warning: return .orange.opacity(0.1)
        case .critical: return .red.opacity(0.1)
        }
    }
}