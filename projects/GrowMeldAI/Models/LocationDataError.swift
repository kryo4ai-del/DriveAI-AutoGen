import Foundation
enum LocationDataError: LocalizedError {
    case bundleFileNotFound(String)
    case invalidData
    case decodingFailed(String)
}

// Enum LocationRepositoryError declared in Models/LocationSelectionRepositoryProtocol.swift
