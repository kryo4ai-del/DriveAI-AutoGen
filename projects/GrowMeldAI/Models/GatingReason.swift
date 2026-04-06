// GatingReason.swift
import Foundation

/// Reason why a feature is gated
enum GatingReason: Equatable {
    case trialNotStarted
    case trialExpired
    case premiumRequired
    case unknown
}