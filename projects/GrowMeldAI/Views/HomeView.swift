// ViewModels/HomeViewModel.swift (EXISTING)
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var learningPlanVM: LearningPlanViewModel?
    
    private let learningPlanService: LearningPlanService
    
    func loadDashboard() async {
        // Load existing category progress, stats, etc.
        
        // NEW: Initialize LP card
        learningPlanVM = LearningPlanViewModel(service: learningPlanService)
        await learningPlanVM?.loadTodayPlan()
    }
}

// Views/HomeView.swift (EXISTING, MODIFIED)
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                // Existing sections
                ProfileSummaryCard()
                
                // NEW: Today's Learning Plan widget
                if let lpVM = viewModel.learningPlanVM {
                    LearningPlanView(viewModel: lpVM)
                }
                
                CategoryProgressView()
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }
}