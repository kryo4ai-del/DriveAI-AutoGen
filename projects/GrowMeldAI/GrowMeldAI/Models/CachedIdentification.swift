// Models/CachedIdentification.swift
import Foundation

struct CachedIdentification: Codable {
    let imageHash: String
    let result: IdentificationResult
    let source: CacheSource
    let cachedAt: Date
    let expiresAt: Date

    var isExpired: Bool { Date() > expiresAt }
}

enum CacheSource: String, Codable {
    case api
    case offline
}