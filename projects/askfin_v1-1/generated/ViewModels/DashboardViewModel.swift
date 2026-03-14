import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var loadState: DashboardLoadState = .idle
    @Published var shouldPresentExamModal = false
    @Published var selectedCategory: String?
    @Published var isRefreshing = false
    
    private let dataService: DashboardDataService
    private var cancellables = Set<AnyCancellable>()
    private var isLoadingInProgress = false
    
    init(dataService: DashboardDataService = .shared) {
        self.dataService = dataService
    }
    
    // MARK: - Data Loading
    
    func loadDashboard() {
        guard !isLoadingInProgress else { return }
        isLoadingInProgress = true
        loadState = .loading
        
        dataService.fetchDashboardContent()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingInProgress = false
                if case .failure(let error) = completion {
                    self.loadState = .error(self.localizedErrorMessage(error))
                }
            } receiveValue: { [weak self] content in
                guard let self = self else { return }
                self.isLoadingInProgress = false
                self.loadState = .loaded(content)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Async Refresh (with MainActor guarantee)
    
    @MainActor
    func refreshDashboard() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            let content = try await dataService.fetchDashboardContentAsync()
            self.loadState = .loaded(content)
        } catch {
            self.loadState = .error(localizedErrorMessage(error))
        }
    }
    
    // MARK: - User Actions
    
    func resumeQuiz(session: QuizSession) {
        // Delegated to parent coordinator for navigation
    }
    
    func startExam() {
        shouldPresentExamModal = true
    }
    
    func browseCategory(_ name: String) {
        selectedCategory = name
    }
    
    func dismissExamModal() {
        shouldPresentExamModal = false
    }
    
    // MARK: - Private Helpers
    
    private func localizedErrorMessage(_ error: Error) -> String {
        if let appError = error as? AppError {
            return appError.userMessage
        }
        
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return String(localized: "error.network.offline", bundle: .module)
        }
        
        return String(localized: "error.generic", bundle: .module)
    }
    
    // MARK: - Cleanup
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Error Protocol (required by dataService)

protocol AppError: Error {
    var userMessage: String { get }
}