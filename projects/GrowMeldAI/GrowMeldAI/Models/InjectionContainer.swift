final class InjectionContainer {
    static let shared = InjectionContainer()
    
    private let queue = DispatchQueue(label: "com.driveai.injection", attributes: .concurrent)
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func makeLocalDataService() throws -> LocalDataService {
        // Synchronous check-and-cache with barrier
        var cached: LocalDataService?
        
        queue.sync {
            cached = services["LocalDataService"] as? LocalDataService
        }
        
        if let cached = cached {
            return cached
        }
        
        let service = try LocalDataService()
        
        // Atomic write
        queue.async(flags: .barrier) { [weak self] in
            self?.services["LocalDataService"] = service
        }
        
        return service
    }
}