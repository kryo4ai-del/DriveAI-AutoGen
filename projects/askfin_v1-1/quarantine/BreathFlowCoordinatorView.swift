import SwiftUI
struct BreathFlowCoordinatorView: View {
    let isFromExam: Bool
    
    @StateObject private var coordinator: BreathFlowCoordinator
    
    init(isFromExam: Bool) {
        self.isFromExam = isFromExam
        _coordinator = StateObject(wrappedValue: BreathFlowCoordinator(isFromExam: isFromExam))
    }
    
    var body: some View {
        NavigationStack {
            switch coordinator.route {
            case .entry:
                BreathFlowEntryView(viewModel: coordinator.entryVM) {
                    coordinator.beginSession()
                }
            case .session:
                BreathFlowSessionView(viewModel: coordinator.sessionVM!) { completed in
                    coordinator.sessionCompleted(completed)
                }
            case .completion:
                BreathFlowCompletionView(viewModel: coordinator.completionVM!) {
                    coordinator.finish()
                }
            }
        }
    }
}

@MainActor
final class BreathFlowCoordinator: ObservableObject {
    @Published private(set) var route: BreathFlowRoute = .entry
    
    let entryVM: BreathFlowEntryViewModel
    private(set) var sessionVM: BreathFlowSessionViewModel?
    private(set) var completionVM: BreathFlowCompletionViewModel?
    
    let isFromExam: Bool
    
    init(isFromExam: Bool) {
        self.isFromExam = isFromExam
        self.entryVM = BreathFlowEntryViewModel()
    }
    
    func beginSession() {
        let session = entryVM.buildSession()
        sessionVM = BreathFlowSessionViewModel(session: session)
        route = .session
    }
    
    func sessionCompleted(_ session: BreathSession) {
        completionVM = BreathFlowCompletionViewModel(
            session: session,
            isFromExam: isFromExam
        )
        route = .completion
    }
    
    func finish() {
        // caller dismisses sheet
    }
}