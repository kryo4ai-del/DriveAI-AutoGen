// Sources/Features/Location/Services/LocationCleanupService.swift
import Foundation
import Combine

@MainActor
final class LocationCleanupService: ObservableObject {
    @Published var lastCleanupDate: Date?
    @Published var deletedCount: Int = 0
    
    private let locationService: LocationDataServiceProtocol
    private var cleanupTask: Task<Void, Never>?
    
    init(locationService: LocationDataServiceProtocol) {
        self.locationService = locationService
    }
    
    // MARK: - Public Methods
    
    func startScheduledCleanup(interval: TimeInterval = 24 * 3600) {
        // Run cleanup every 24 hours
        cleanupTask = Task {
            while !Task.isCancelled {
                try? await cleanup()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopScheduledCleanup() {
        cleanupTask?.cancel()
        cleanupTask = nil
    }
    
    func cleanup() async {
        do {
            let count = try await locationService.deleteExpiredLocations(retentionDays: 30)
            self.deletedCount = count
            self.lastCleanupDate = Date()
            
            if count > 0 {
                print("🗑️ Deleted \(count) expired location records")
            }
        } catch {
            print("❌ Cleanup failed: \(error)")
        }
    }
    
    deinit {
        stopScheduledCleanup()
    }
}