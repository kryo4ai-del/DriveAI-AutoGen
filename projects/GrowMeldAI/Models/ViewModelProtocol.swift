// MARK: - Base Pattern
import Combine
protocol ViewModelProtocol: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
}

// MARK: - Example: QuestionViewModel