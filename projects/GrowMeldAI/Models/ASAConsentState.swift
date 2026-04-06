// File: DriveAI/Features/ASA/Models/ASAConsentState.swift
import Foundation

/// Represents the consent state for Apple Search Ads tracking
enum ASAConsentState: String, Codable {
    case unknown
    case granted
    case denied
    case restricted

    var isGranted: Bool {
        self == .granted
    }
}