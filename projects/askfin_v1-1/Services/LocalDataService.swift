import Foundation

protocol UserProgressServiceProtocol: Sendable {
    func getOverallProgress() async throws -> Double
}

final class LocalDataService: LocalDataServiceProtocol, @unchecked Sendable {
    static let preview = LocalDataService()

    // Methods implemented in LocalDataService+Extension.swift
}
