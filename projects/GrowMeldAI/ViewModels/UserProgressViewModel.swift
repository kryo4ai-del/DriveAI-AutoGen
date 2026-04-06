// ✅ FIXED

// Usage:
@Observable
final class UserProgressViewModel {
    private let dataService: LocalDataService
    var progress: Progress?
    
    func loadProgress() async {
        do {
            progress = try await dataService.loadProgress()
        } catch {
            // Handle error gracefully
        }
    }
}