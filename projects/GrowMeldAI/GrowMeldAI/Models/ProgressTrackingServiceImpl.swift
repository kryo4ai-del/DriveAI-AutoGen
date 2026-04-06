@MainActor
final class ProgressTrackingServiceImpl: ProgressTrackingService {
    @Published private(set) var categoryProgress: [String: UserProgress] = [:]
    
    nonisolated private let queue = DispatchQueue(label: "com.driveai.progress", attributes: .concurrent)
    
    func recordAnswer(...) async {
        let newProgress = queue.sync {
            // Atomic read + modify
            var p = categoryProgress[categoryId] ?? UserProgress(id: categoryId)
            p.attemptedCount += 1
            // ...
            return p
        }
        
        await MainActor.run {
            categoryProgress[categoryId] = newProgress
            saveProgress()
        }
    }
}