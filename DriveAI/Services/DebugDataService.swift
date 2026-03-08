import Foundation
import Combine

class DebugDataService {
    
    func retrieveDebugData() -> AnyPublisher<[DebugInfo], Never> {
        let logs: [DebugInfo] = [
            DebugInfo(timestamp: Date(), message: "Loaded questions successfully.", level: .info),
            DebugInfo(timestamp: Date(), message: "User selected category: Traffic signs.", level: .info),
            DebugInfo(timestamp: Date(), message: "Question timed out.", level: .warning)
        ]
        
        return Just(logs)
            .delay(for: 1.0, scheduler: RunLoop.main) // Simulate network delay
            .eraseToAnyPublisher()
    }
}