// Services/Container/PerformanceServiceContainer.swift
protocol PerformanceServiceContainer {
    var dataService: PerformanceDataService { get }
    var performanceManager: PerformanceManager { get }
}

class DefaultPerformanceServiceContainer: PerformanceServiceContainer {
    let dataService: PerformanceDataService
    let performanceManager: PerformanceManager
    
    init(storageType: StorageType = .sqlite) {
        self.dataService = SQLitePerformanceDataService() // or JSONPerformanceDataService()
        self.performanceManager = PerformanceManager(dataService: dataService)
    }
}