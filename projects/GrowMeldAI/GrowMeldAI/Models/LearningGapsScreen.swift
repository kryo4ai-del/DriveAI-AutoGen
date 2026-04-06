// Services/ServiceContainer.swift

// Usage in SwiftUI
struct LearningGapsScreen: View {
    @StateObject private var viewModel: LearningGapsViewModel
    
    init(userId: String) {
        let container = ServiceContainer.shared
        _viewModel = StateObject(
            wrappedValue: container.createLearningGapsViewModel(userId: userId)
        )
    }
    
    var body: some View {
        // ...
    }
}