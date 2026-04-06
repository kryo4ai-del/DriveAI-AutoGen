import SwiftUI
// Views/Questions/ProgressBarView.swift
struct ProgressBarView: View {
    let currentIndex: Int
    let totalQuestions: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Frage \(currentIndex + 1) von \(totalQuestions)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(progressPercentage)%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Fortschritt: Frage \(currentIndex + 1) von \(totalQuestions)")
            
            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(totalQuestions)
            )
            .tint(.blue)
            .accessibilityValue("\(progressPercentage)% abgeschlossen")
        }
        .padding(.horizontal)
    }
    
    private var progressPercentage: Int {
        Int(Double(currentIndex + 1) / Double(totalQuestions) * 100)
    }
}