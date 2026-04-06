// MARK: - Views/Components/ProgressIndicator.swift

import SwiftUI

struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var progress: Double {
        Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Schritt \(current) von \(total)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(.blue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Fortschritt: \(current) von \(total)")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}

#Preview {
    ProgressIndicator(current: 2, total: 3)
        .padding()
}