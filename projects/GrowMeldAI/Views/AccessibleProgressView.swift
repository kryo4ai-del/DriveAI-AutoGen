// Views/Components/AccessibleProgressView.swift

import SwiftUI

struct AccessibleProgressView: View {
    let value: Double
    let label: String
    let maximum: Double
    
    var percentage: Int {
        Int((value / maximum) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                
                Spacer()
                
                Text("\(percentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            
            ProgressView(value: value, total: maximum)
                .frame(height: 12)
                .accessibilityLabel(label)
                .accessibilityValue("\(percentage)% complete")
        }
        .accessibilityElement(children: .combine)
    }
}

// Streak indicator with accessible context
struct StreakIndicator: View {
    let count: Int
    let bestCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(count) day\(count == 1 ? "" : "s")")
                        .font(.headline)
                }
            }
            
            if bestCount > count {
                Text("Best: \(bestCount) days")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Best streak: \(bestCount) days")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Streak")
        .accessibilityValue("\(count) days, personal best \(bestCount) days")
    }
}

#Preview {
    VStack(spacing: 24) {
        AccessibleProgressView(
            value: 18,
            label: "Category Progress",
            maximum: 40
        )
        
        StreakIndicator(count: 5, bestCount: 12)
    }
    .padding()
}