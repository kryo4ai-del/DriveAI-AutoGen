// ═══════════════════════════════════════════════════════
// DOMAIN LAYER (Business Logic)
// ═══════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════
// COORDINATOR (Navigation Logic)
// ═══════════════════════════════════════════════════════

class QuickAccessCoordinator {
    private let quickAccessService: QuickAccessService
    @Published var navigationPath: NavigationPath?
    
    func handleQuickAccessTapped(
        accessPoint: AccessPoint,
        userState: UserState
    ) async {
        do {
            let path = try await quickAccessService.resolveNavigationPath(
                from: accessPoint,
                userState: userState
            )
            let context = try await quickAccessService.createLaunchContext(for: path)
            self.navigationPath = path  // Trigger SwiftUI navigation
        } catch {
            // Handle error
        }
    }
}

// ═══════════════════════════════════════════════════════
// PRESENTATION LAYER (MVVM)
// ═══════════════════════════════════════════════════════

class QuickAccessButtonViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: QuickAccessError?
    
    private let coordinator: QuickAccessCoordinator
    private let userState: UserState
    
    func tappedQuickAccess() {
        Task {
            isLoading = true
            await coordinator.handleQuickAccessTapped(
                accessPoint: .homeScreenButton,
                userState: userState
            )
            isLoading = false
        }
    }
}

// ═══════════════════════════════════════════════════════
// VIEW LAYER (SwiftUI)
// ═══════════════════════════════════════════════════════

struct QuickAccessButton: View {
    @StateObject var viewModel: QuickAccessButtonViewModel
    @StateObject var coordinator: QuickAccessCoordinator
    
    var body: some View {
        Button(action: { viewModel.tappedQuickAccess() }) {
            HStack {
                Image(systemName: "bolt.fill")
                Text("Quick Review")
            }
            .disabled(viewModel.isLoading)
        }
        .navigationDestination(
            isPresented: .constant(coordinator.navigationPath != nil)
        ) {
            // Navigate to quiz based on coordinator.navigationPath
            if let path = coordinator.navigationPath {
                QuizViewFactory.makeView(for: path)
            }
        }
    }
}