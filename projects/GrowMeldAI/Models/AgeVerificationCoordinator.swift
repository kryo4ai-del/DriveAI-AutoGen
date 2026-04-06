// Coordinator handles flow logic
class AgeVerificationCoordinator: ObservableObject {
    @Published var step: AgeVerificationStep = .ageInput
    @Published var viewModel: AgeVerificationViewModel
    
    func advance() {
        // Validate current step before advancing
        step = step.next(viewModel)
    }
    
    func back() {
        step = step.previous
    }
}