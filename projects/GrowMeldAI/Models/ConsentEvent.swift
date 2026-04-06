// ConsentManager.swift
import Foundation
import UserNotifications
import Combine

enum ConsentEvent: String {
    case granted
    case revoked
    case requested
    case failed
}

// ConsentAuditLog declared in Models/ConsentAuditLog.swift

private struct ConsentLogEntry: Codable {
    let event: String
    let timestamp: Date
}