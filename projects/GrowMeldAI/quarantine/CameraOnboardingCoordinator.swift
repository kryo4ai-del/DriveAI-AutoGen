// Features/CameraOnboarding/Coordinator/CameraOnboardingCoordinator.swift
@MainActor
final class CameraOnboardingCoordinator {
    weak var navigationController: UINavigationController?
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func start() {
        let viewModel = container.resolve(CameraOnboardingViewModel.self)
        let view = CameraOnboardingView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// Features/CameraOnboarding/Presentation/ViewModels/CameraOnboardingViewModel.swift
@MainActor
final class CameraOnboardingViewModel: ObservableObject {
    @Published var currentState: LicenseCaptureState = .initial
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let repository: LicenseCaptureRepository
    
    init(repository: LicenseCaptureRepository) {
        self.repository = repository
    }
    
    // MARK: - Flow Methods
    func requestPermission() async {
        do {
            let decision = try await repository.requestCameraPermission()
            currentState = decision.isGranted ? .capturing : .permissionNeeded
        } catch {
            errorMessage = "Kamera-Berechtigung erforderlich"
            currentState = .error
        }
    }
    
    func captureImage(_ image: UIImage) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let capturedImage = try await repository.processAndStoreLicense(image)
            currentState = .confirmed
            // Trigger post-capture engagement
            await notifyPostCaptureEngagement()
        } catch {
            errorMessage = error.localizedDescription
            currentState = .error
        }
    }
    
    private func notifyPostCaptureEngagement() async {
        // Integration hook for UX psychology agent
    }
}