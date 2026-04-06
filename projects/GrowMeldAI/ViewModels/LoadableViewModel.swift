// Use composition instead of inheritance
protocol LoadableViewModel: AnyObject, ObservableObject {
    var isLoading: Bool { get set }
}

protocol ErrorHandlingViewModel: AnyObject, ObservableObject {
    var errorMessage: String? { get set }
    var showError: Bool { get set }
    func handleError(_ error: Error)
}

// Now ViewModels adopt only what they need

// Settings VM doesn't need loading or error handling
class SettingsViewModel: ObservableObject {
    @Published var isDarkMode = false
    @Published var language: Language = .german
}