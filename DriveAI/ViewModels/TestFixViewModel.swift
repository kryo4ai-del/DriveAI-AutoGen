import SwiftUI
import Combine

class TestFixViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dataService: DataServiceProtocol

    // Dependency Injection for better testability
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
        fetchTestFixData()
    }
    
    func fetchTestFixData() {
        // Main thread for UI updates
        DispatchQueue.main.async { self.isLoading = true }
        
        dataService.loadQuestions { [weak self] result in
            DispatchQueue.main.async {
                self?.handleDataFetch(result: result)
            }
        }
    }

    private func handleDataFetch(result: Result<[Question], DataServiceError>) {
        self.isLoading = false // Ensure this is executed on the main thread
        switch result {
        case .success(let fetchedQuestions):
            self.questions = fetchedQuestions
            self.errorMessage = fetchedQuestions.isEmpty ? "Keine Fragen verfügbar." : nil
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
}