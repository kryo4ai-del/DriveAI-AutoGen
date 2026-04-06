import Foundation

/// Self-Determination Theory compliance levels
enum ConsentStatus: String, Codable, Equatable {
    case undetermined  // User hasn't seen consent prompt
    case granted       // User explicitly allowed Meta tracking
    case denied        // User explicitly rejected Meta tracking
    
    var isGranted: Bool { self == .granted }
    var isDetermined: Bool { self != .undetermined }
}

// Enum ConsentStorageError declared in Models/ConsentStorageServiceProtocol.swift
