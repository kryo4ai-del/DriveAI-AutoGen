// LocalToxicityWarningService.swift
import Foundation

final class LocalToxicityWarningService: ToxicityWarningDataService {
    private let jsonDecoder = JSONDecoder()

    func fetchAllWarnings() async throws -> [ToxicityWarning] {
        // In a real implementation, this would load from a local database or bundle
        // For now, return empty array to prevent any warnings from showing
        return []
    }

    func fetchWarning(withId id: String) async throws -> ToxicityWarning? {
        // Implementation would fetch from local storage
        return nil
    }
}