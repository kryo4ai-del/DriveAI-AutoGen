enum BreathFlowRoute: Hashable {
    case session(BreathFlowSessionViewModel)
    case exam
    case dismiss
}

// In ViewModel:
@Published var route: BreathFlowRoute?