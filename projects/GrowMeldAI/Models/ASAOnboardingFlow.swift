// File: DriveAI/Features/ASA/Views/ASAOnboardingFlow.swift
import SwiftUI

/// Onboarding flow that includes ASA compliance
struct ASAOnboardingFlow: View {
    @State private var currentStep = 0
    @State private var hasCompletedASA = false

    private let steps: [OnboardingStep] = [
        .init(
            title: "Dein Weg zur Prüfungsreife",
            subtitle: "Wir helfen dir, gesehen zu werden",
            image: "target",
            view: AnyView(ASAComplianceView())
        ),
        .init(
            title: "Lernfortschritt verfolgen",
            subtitle: "Behalte deinen Erfolg im Blick",
            image: "chart.line.uptrend.xyaxis",
            view: AnyView(ProgressTrackingView())
        ),
        .init(
            title: "Prüfungssimulationen",
            subtitle: "Übe unter echten Bedingungen",
            image: "graduationcap",
            view: AnyView(ExamSimulationView())
        )
    ]

    var body: some View {
        NavigationStack {
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack {
                        steps[index].view
                            .tag(index)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(alignment: .bottom) {
                VStack {
                    Spacer()

                    stepIndicator

                    nextButton
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemBackground).opacity(0.8), Color(.systemBackground)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .animation(.easeInOut, value: currentStep)
        }
    }

    private var stepIndicator: some View {
        HStack {
            ForEach(0..<steps.count, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(index == currentStep ? .blue : .gray.opacity(0.5))
            }
        }
    }

    private var nextButton: some View {
        Button(action: {
            if currentStep < steps.count - 1 {
                currentStep += 1
            } else {
                // Onboarding complete
            }
        }) {
            Text(currentStep < steps.count - 1 ? "Weiter" : "Starten")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 20)
    }
}

private struct ProgressTrackingView: View {
    var body: some View {
        Text("Lernfortschritt verfolgen")
            .font(.title)
    }
}
