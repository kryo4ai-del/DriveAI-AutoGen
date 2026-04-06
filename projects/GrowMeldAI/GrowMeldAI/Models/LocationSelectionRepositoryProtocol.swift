import Foundation

// MARK: - Protocols

/// Protocol for location selection persistence
protocol LocationSelectionRepositoryProtocol: Sendable {
    func saveSelection(_ location: Location) async throws
    func getLastSelection() async throws -> CachedLocationSelection?
    func clearSelection() async throws
    func hasSelection() async throws -> Bool
}

// MARK: - Implementation

/// Manages user's location selection persistence across app sessions
final class LocationSelectionRepository: LocationSelectionRepositoryProtocol {
    static let shared = LocationSelectionRepository()
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageKey = "com.driveai.location.last-selection"
    
    private init() {}
    
    // MARK: - Public API
    
    func saveSelection(_ location: Location) async throws {
        let selection = CachedLocationSelection(
            location: location,
            selectedAt: Date()
        )
        
        do {
            let encoded = try encoder.encode(selection)
            defaults.set(encoded, forKey: storageKey)
        } catch {
            throw LocationRepositoryError.encodingFailed
        }
    }
    
    func getLastSelection() async throws -> CachedLocationSelection? {
        guard let data = defaults.data(forKey: storageKey) else {
            return nil
        }
        
        do {
            return try decoder.decode(CachedLocationSelection.self, from: data)
        } catch {
            // Silently remove corrupted cache
            defaults.removeObject(forKey: storageKey)
            return nil
        }
    }
    
    func clearSelection() async throws {
        defaults.removeObject(forKey: storageKey)
    }
    
    func hasSelection() async throws -> Bool {
        guard let selection = try await getLastSelection() else {
            return false
        }
        return !selection.isStale
    }
}

// MARK: - Error Types

enum LocationRepositoryError: LocalizedError, Equatable {
    case encodingFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return LocationStrings.Errors.encodingFailed
        case .saveFailed:
            return LocationStrings.Errors.saveFailed
        }
    }
}