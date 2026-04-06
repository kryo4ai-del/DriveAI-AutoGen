// File: ConfidenceMeterView.swift
import SwiftUI

struct ConfidenceMeterView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deine Prüfungsbereitschaft")
                .font(.headline)
                .foregroundColor(.secondary)

            Gauge(value: coordinator.userProgress.readinessScore, in: 0...100) {
                Text("\(Int(coordinator.userProgress.readinessScore))%")
            } currentValueLabel: {
                Image(systemName: "brain.head.profile")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(coordinator.userProgress.readinessScore >= 85 ? .green : .blue)

            Text(coordinator.userProgress.motivationalMessage)
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}