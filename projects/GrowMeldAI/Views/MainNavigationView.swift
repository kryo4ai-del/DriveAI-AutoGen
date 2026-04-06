// App/Router.swift
@MainActor

// App/AppState.swift
@MainActor

// App/DriveAIApp.swift
@main

// App/MainNavigationView.swift
struct MainNavigationView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $appState.router.navigationPath) {
            DashboardView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    destinationView(for: destination)
                }
                .sheet(item: $appState.router.presentedSheet) { sheet in
                    sheetView(for: sheet)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: Router.Destination) -> some View {
        switch destination {
        case .category(let categoryID):
            CategoryDetailView(categoryID: categoryID)
        case .question(let questionID, let categoryID):
            QuestionView(questionID: questionID, categoryID: categoryID)
        case .exam:
            ExamContainerView()
        case .examResult(let result):
            ResultView(examResult: result)
        case .profile:
            ProfileView()
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Router.Sheet) -> some View {
        switch sheet {
        case .examSummary(let session):
            ExamSummarySheet(session: session)
        case .settings:
            SettingsView()
        }
    }
}