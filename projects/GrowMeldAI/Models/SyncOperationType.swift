import Foundation

enum SyncOperationType: String, Codable {
    case updateProgress
    case updateProfile
    case deleteProgress
}

// Enum SyncStatus declared in Models/SyncStatus.swift
