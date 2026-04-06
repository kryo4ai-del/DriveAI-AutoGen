import SwiftUI
import os.log

@MainActor
final class MaintenanceDashboardViewModel: ObservableObject {
    @Published var checks: [CategoryMaintenanceCheck] = []
    @Published var isLoading = false
    @Published var maintenanceOnly = false
    @Published var error: String?
    
    private let service = MaintenanceCheckService.shared
    private let categories: [QuizCategory]
    private let logger = Logger(subsystem: "com.driveai.maintenance", category: "Dashboard")
    
    init(categories: [QuizCategory]) {
        self.categories = categories
        load()
    }
    
    func load() {
        isLoading = true
        error = nil
        
        let allChecks = service.getMaintenanceChecks(categories: categories)
        
        checks = maintenanceOnly
            ? allChecks.filter { $0.status == .needsMaintenance }
            : allChecks
        
        isLoading = false
        logger.debug("Loaded \(self.checks.count) maintenance checks")
    }
    
    func toggleMaintenanceOnly() {
        maintenanceOnly.toggle()
        load()
    }
}