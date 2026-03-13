import SwiftUI

struct PremiumDashboardView: View {
    @StateObject private var viewModel = PremiumDashboardViewModel()
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            contentSwitch()
        }
        .navigationTitle("Dashboard")
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            if case .idle = viewModel.loadState {
                viewModel.loadDashboard()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.refreshDashboard()
                }
            }
        }
        .sheet(isPresented: $viewModel.shouldPresentExamModal) {
            NavigationStack {
                ExamStartModal(
                    isPresented: $viewModel.shouldPresentExamModal,
                    onStartExam: { duration in
                        handleExamStart(duration: duration)
                    }
                )
            }
        }
        .navigationDestination(item: $viewModel.selectedCategory) { category in
            CategoryDetailView(category: category)
        }
    }
    
    @ViewBuilder
    private func contentSwitch() -> some View {
        switch viewModel.loadState {
        case .idle, .loading:
            DashboardLoadingView()
            
        case .loaded(let content):
            loadedContent(content)
            
        case .error(let message):
            DashboardErrorView(
                message: message,
                retryAction: {
                    // Clear state before retry (prevents stale data display)
                    viewModel.loadState = .loading
                    viewModel.loadDashboard()
                }
            )
        }
    }
    
    @ViewBuilder
    private func loadedContent(_ content: DashboardContent) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                ExamCountdownCard(countdown: content.examCountdown)
                    .padding(.horizontal)
                
                StreakIndicator(streak: content.streakData)
                    .padding(.horizontal)
                
                ProgressGridCard(summary: content.progressSummary)
                    .padding(.horizontal)
                
                if let quiz = content.resumableQuiz {
                    ResumableQuizCard(
                        quiz: quiz,
                        onResume: { viewModel.resumeQuiz(session: quiz) }
                    )
                    .padding(.horizontal)
                }
                
                QuickActionButtons(
                    onStartExam: { viewModel.startExam() },
                    onBrowseCategories: { viewModel.browseCategory("all") }
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refreshDashboard()
        }
    }
    
    private func handleExamStart(duration: TimeInterval) {
        // Delegate to coordinator/parent
        viewModel.dismissExamModal()
        // Parent handles: @State private var examRoute: ExamRoute?
        // navigationDestination(item: $examRoute) { ... }
    }
}

#Preview {
    NavigationStack {
        PremiumDashboardView()
    }
}
