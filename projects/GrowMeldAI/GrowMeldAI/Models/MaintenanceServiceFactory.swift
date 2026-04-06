// In Services/MaintenanceService/MaintenanceServiceFactory.swift
@MainActor
final class MaintenanceServiceFactory {
    private let statsService: StatsService
    private let categoryService: CategoryService
    private let persistence: MaintenancePersistenceService
    
    init(
        statsService: StatsService,
        categoryService: CategoryService,
        persistence: MaintenancePersistenceService
    ) {
        self.statsService = statsService
        self.categoryService = categoryService
        self.persistence = persistence
    }
    
    func makeMaintenanceCheckService() -> MaintenanceCheckService {
        DefaultMaintenanceCheckService(
            statsService: statsService,
            categoryService: categoryService,
            persistenceService: persistence
        )
    }
}