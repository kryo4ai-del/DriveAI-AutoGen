import SwiftUI

struct LearningPlanView: View {
    @ObservedObject var viewModel: LearningPlanViewModel
    @State private var showWeakCategories = false

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let plan):
                contentView(for: plan)

            case .error(let error):
                ErrorView(error: error) {
                    await viewModel.refreshPlan()
                }

            case .empty:
                LearningPlanEmptyView {
                    await viewModel.loadTodayPlan()
                }
            }
        }
        .task {
            if viewModel.state == .idle {
                await viewModel.loadTodayPlan()
            }
        }
    }

    @ViewBuilder
    private func contentView(for plan: LearningPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            if !viewModel.todayRecommendations.isEmpty {
                TodayRecommendationsView(
                    recommendations: viewModel.todayRecommendations,
                    onQuestionSelected: { questionId in
                        // Handle question selection
                    }
                )
            }

            if !viewModel.weakCategories.isEmpty {
                WeakCategoriesView(
                    categories: viewModel.weakCategories,
                    onExpand: { showWeakCategories.toggle() }
                )
                .sheet(isPresented: $showWeakCategories) {
                    WeakCategoriesDetailView(categories: viewModel.weakCategories)
                }
            }

            Spacer()
        }
        .padding()
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dein Lernplan")
                .font(.title2)
                .fontWeight(.bold)

            if let daysLeft = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: viewModel.userProfile.examDate
            ).day, daysLeft > 0 {
                Text("Noch \(daysLeft) Tage bis zur Prüfung")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if case .loaded(let plan) = viewModel.state {
                PlanStatusView(status: plan.status)
            }
        }
    }
}

private struct PlanStatusView: View {
    let status: LearningPlan.PlanStatus

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(statusColor)

            Text(statusText)
                .font(.caption)
        }
    }

    private var statusColor: Color {
        switch status {
        case .active: return .green
        case .completed: return .blue
        case .expired: return .red
        }
    }

    private var statusText: String {
        switch status {
        case .active: return "Aktiv"
        case .completed: return "Abgeschlossen"
        case .expired: return "Abgelaufen"
        }
    }
}

private struct ErrorView: View {
    let error: LearningPlanError
    let onRetry: () async -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text(error.localizedDescription)
                .font(.headline)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                Task { await onRetry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}