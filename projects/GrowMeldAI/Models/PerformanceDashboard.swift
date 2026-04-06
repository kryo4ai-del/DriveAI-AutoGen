struct PerformanceDashboard: View {
    @StateObject private var viewModel = PerformanceTrackingViewModel()
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.categoryStats.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            DashboardHeaderView()
                            
                            if let readiness = viewModel.examReadiness {
                                ExamReadinessGaugeCard(readiness: readiness)
                            }
                            
                            CategoryPerformanceGrid(stats: viewModel.categoryStats)
                            
                            if !viewModel.spacedRepetitionQueue.isEmpty {
                                SpacedRepetitionQueuePreview(
                                    items: Array(viewModel.spacedRepetitionQueue.prefix(5))
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Leistung")
            .task {
                await viewModel.loadPerformanceData()
            }
            .refreshable {
                await viewModel.refreshPerformanceData()
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}