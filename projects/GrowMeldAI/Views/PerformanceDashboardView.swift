struct PerformanceDashboardView: View {
    @StateObject private var viewModel: PerformanceTrackingViewModel
    @Environment(\.sizeCategory) var sizeCategory
    
    init(service: PerformanceServiceProtocol = PerformanceService()) {
        _viewModel = StateObject(wrappedValue: PerformanceTrackingViewModel(service: service))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            contentView
                .accessibilityElement(children: .contain)
        }
        .navigationTitle(Strings.PerformanceTracking.title)
        .onAppear {
            viewModel.loadPerformanceData()
        }
        .refreshable {
            viewModel.loadPerformanceData()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
            
        case .success:
            successView
            
        case .error(let message):
            errorView(message)
        }
    }
    
    // MARK: Loading State
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
            Text(Strings.PerformanceTracking.loading)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: Error State
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.retry) {
                Text(Strings.Common.retry)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: Success State
    private var successView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // PRIMARY: Exam Readiness
                if let readiness = viewModel.examReadiness {
                    ExamReadinessGaugeView(data: readiness)
                        .accessibilityElement(children: .combine)
                }
                
                Divider()
                
                // SECONDARY: Recommended Review
                if let recommended = viewModel.getRecommendedCategory() {
                    RecommendedReviewCardView(category: recommended)
                        .accessibilityElement(children: .combine)
                }
                
                // TERTIARY: Collapsible Details
                DisclosureGroup(Strings.PerformanceTracking.detailedStats) {
                    PerformanceDetailsView(metrics: viewModel.metrics)
                }
                .accessibilityHint("Erweitert Detailansicht der Statistiken")
                
                Spacer()
            }
            .padding()
        }
    }
}