// Core protocol for consistency
protocol DriveAIViewModel: ObservableObject {
    associatedtype State
    var state: State { get set }
    func reset()
}

// Example: QuestionScreenViewModel