// Services/APIFallback/APIFallbackStrategy.swift
import Foundation

protocol APIFallbackStrategy: Sendable {
    associatedtype T: Sendable
    
    func fetchWithFallback() async throws -> T
    func cacheResult(_ data: T) async throws
    func retrieveCached() async throws -> T?
}
