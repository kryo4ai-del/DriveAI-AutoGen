final class DependencyContainer {
    static let shared = DependencyContainer()
    
    nonisolated(unsafe) private lazy var _localDataService = LocalDataServiceImpl(...)
    
    var localDataService: LocalDataServiceProtocol {
        _localDataService
    }
}