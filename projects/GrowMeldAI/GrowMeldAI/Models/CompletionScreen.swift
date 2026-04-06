// CompletionScreen.swift
import SwiftUI

struct CompletionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerView
                studyPlanView
                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Fast geschafft!")
                .font(.system(size: 28, weight: .bold))

            if let days = viewModel.daysUntilExam {
                Text("Du hast noch \(days) Tage bis zur Prüfung")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var studyPlanView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dein persönlicher Lernplan")
                .font(.system(size: 20, weight: .semibold))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "target")
                    Text("Ziel: Bestehen der Theorieprüfung")
                }

                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Tägliches Ziel: 15 Fragen zu \(viewModel.selectedCategories.first ?? "Verkehrszeichen")")
                }

                HStack {
                    Image(systemName: "calendar")
                    Text("Wiederholungen basierend auf deinem Lernfortschritt")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                appState.completeOnboarding(with: viewModel.userProfile)
            }) {
                Text("Jetzt mit Lernen beginnen")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Später entscheiden") {
                appState.completeOnboarding(with: viewModel.userProfile)
            }
            .foregroundColor(.secondary)
        }
    }
}