import Foundation

final class LocationSelectionRepository: LocationSelectionRepositoryProtocol {
    static let shared = LocationSelectionRepository()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageKey = "com.driveai.location.last-selection"

    private init() {}

    func saveSelection(_ location: Location) async throws {
        let selection = CachedLocationSelection(location: location, selectedAt: Date())
        let encoded = try encoder.encode(selection)

        return try await Task.detached { [weak self] in
            guard let self = self else { throw LocationError.serviceUnavailable }
            self.defaults.set(encoded, forKey: self.storageKey)
        }.value
    }

    func getLastSelection() async throws -> CachedLocationSelection? {
        return try await Task.detached { [weak self] () -> CachedLocationSelection? in
            guard let self = self,
                  let data = self.defaults.data(forKey: self.storageKey) else {
                return nil
            }

            do {
                return try self.decoder.decode(CachedLocationSelection.self, from: data)
            } catch {
                // Silently remove corrupted cache
                self.defaults.removeObject(forKey: self.storageKey)
                return nil
            }
        }.value
    }

    func clearSelection() async throws {
        return try await Task.detached { [weak self] in
            guard let self = self else { throw LocationError.serviceUnavailable }
            self.defaults.removeObject(forKey: self.storageKey)
        }.value
    }

    func hasSelection() async throws -> Bool {
        let selection = try await getLastSelection()
        return selection.map { !$0.isStale } ?? false
    }
}