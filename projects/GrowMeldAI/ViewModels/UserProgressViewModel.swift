import Foundation
import Observation

@Observable
final class UserProgressViewModel {
    private let dataService: LocalDataService
    var progress: Progress?
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    func loadProgress() async {
        do {
            progress = try await dataService.loadProgress()
        } catch {
            // Handle error gracefully
        }
    }
}

protocol LocalDataService {
    func loadProgress() async throws -> Progress
}