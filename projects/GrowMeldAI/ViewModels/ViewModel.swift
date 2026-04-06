// Base protocol for all ViewModels
protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
}

// Example: QuestionViewModel