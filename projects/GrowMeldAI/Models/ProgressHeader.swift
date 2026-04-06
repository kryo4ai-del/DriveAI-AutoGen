// Features/Onboarding/Views/Components/ProgressHeader.swift
import SwiftUI

struct ProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Schritt \(currentStep) von \(totalSteps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(title)
                    .font(.headline)
            }

            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .tint(.blue)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}