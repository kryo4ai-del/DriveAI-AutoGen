import Combine

enum BreathFlowRoute: Hashable {
    case session(BreathFlowSessionViewModel)
    case exam
    case dismiss
}

// In ViewModel:
class BreathFlowViewModel: ObservableObject {
    @Published var route: BreathFlowRoute?
}

class BreathFlowSessionViewModel: Hashable {
    static func == (lhs: BreathFlowSessionViewModel, rhs: BreathFlowSessionViewModel) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}