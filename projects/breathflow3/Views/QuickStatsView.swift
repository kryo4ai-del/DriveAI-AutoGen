// Views/Components/QuickStatsView.swift
import SwiftUI

struct QuickStatsView: View {
    let stats: UserSessionStats?
    
    var body: some View {
        if let stats = stats {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Label("\(stats.completedCount)", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Label(String(format: "%.0f%%", stats.bestScore), systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Sessions: \(stats.completedCount), Best Score: \(Int(stats.bestScore))%")
            }
        } else {
            Text("Not started")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Exercise not yet started")
        }
    }
}