// MARK: - Models/ConsentState.swift

import Foundation

enum ConsentState: String, Codable, Equatable {
    case pending           // User hasn't encountered consent yet
    case accepted          // User accepted; permission granted
    case declined          // User explicitly declined
    case permissionDenied  // System permission was denied
    case deferred          // Will retry after grace period
    case dismissed         // User dismissed without choosing

    var isResolved: Bool {
        self != .pending && self != .deferred
    }
}