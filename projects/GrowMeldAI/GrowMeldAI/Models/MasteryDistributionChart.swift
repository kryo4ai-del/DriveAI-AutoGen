// Views/Charts/MasteryDistributionChart.swift
import SwiftUI
import Charts

struct MasteryDistributionChart: View {
    let distribution: [MasteryLevel: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lernfortschritt")
                .font(.headline)
            
            Chart {
                ForEach(MasteryLevel.allCases, id: \.self) { level in
                    BarMark(
                        x: .value("Level", level.rawValue),
                        y: .value("Count", distribution[level] ?? 0)
                    )
                    .foregroundStyle(colorForLevel(level))
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks()
            }
            .accessibilityLabel("Mastery Distribution Chart")
            .accessibilityValue(chartDescription)
        }
        .padding()
    }
    
    private var chartDescription: String {
        distribution.map { level, count in
            "\(level.rawValue): \(count)"
        }
        .joined(separator: ", ")
    }
    
    private func colorForLevel(_ level: MasteryLevel) -> Color {
        switch level {
        case .novice: return .red
        case .developing: return .orange
        case .proficient: return .yellow
        case .mastered: return .green
        }
    }
}