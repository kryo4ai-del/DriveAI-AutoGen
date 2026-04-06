// MARK: - Base Pattern
protocol ViewModelProtocol: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
}

// MARK: - Example: QuestionViewModel