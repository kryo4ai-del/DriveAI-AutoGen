import Foundation
import Combine

// MARK: - Maintenance Check ViewModel (Fixed for concurrency & scheduling)

@MainActor
class MaintenanceCheckViewModel: ObservableObject {
    // MARK: Published Properties
    
    @Published var maintenanceItems: [MaintenanceItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var examReadinessMetrics: ExamReadinessMetrics = .init(maintenanceItems: [])
    
    // MARK: Private Properties
    
    private let maintenanceService: MaintenanceService
    private var refreshTask: Task<Void, Never>?
    
    // MARK: Init
    
    init(maintenanceService: MaintenanceService) {
        self.maintenanceService = maintenanceService
        // FIXED: Load data at init, not in onAppear (prevents race conditions)
        Task {
            await self.loadMaintenanceStatus()
        }
    }
    
    // MARK: Public Methods
    
    /// Load maintenance status for all categories (safe: serialized via @MainActor)
    func refreshMaintenanceStatus() {
        Task {
            await loadMaintenanceStatus()
        }
    }
    
    /// Start quick 5-question refresh quiz for a category
    func startQuickRefresh(for categoryId: String) {
        // TODO: Navigate to QuizViewController with filtered questions
        print("Starting quick refresh for category: \(categoryId)")
    }
    
    // MARK: Private Methods
    
    /// FIXED: Centralized load logic (handles concurrency, edge cases)
    private func loadMaintenanceStatus() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let items = try await maintenanceService.fetchMaintenanceItems()
            
            // Update both items and metrics atomically
            self.maintenanceItems = items
            self.examReadinessMetrics = ExamReadinessMetrics(maintenanceItems: items)
            
        } catch {
            self.errorMessage = "Wartungsstatus konnte nicht geladen werden."
            print("MaintenanceCheckViewModel error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    deinit {
        refreshTask?.cancel()  // Clean up background task
    }
}

// MARK: - Computed Properties for UI

extension MaintenanceCheckViewModel {
    var categoryCoverage: Double {
        examReadinessMetrics.coverage
    }
    
    var examReadinessScore: Double {
        examReadinessMetrics.score
    }
    
    var readinessMessage: String {
        examReadinessMetrics.message
    }
    
    /// Items sorted: active first, then needs maintenance, then dormant
    var sortedMaintenanceItems: [MaintenanceItem] {
        maintenanceItems.sorted { a, b in
            let statusOrder: [MaintenanceStatus] = [.active, .needsMaintenance, .dormant]
            guard let aIndex = statusOrder.firstIndex(of: a.status),
                  let bIndex = statusOrder.firstIndex(of: b.status) else {
                return false
            }
            return aIndex < bIndex
        }
    }
}