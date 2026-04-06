// GateStatus.swift
import Foundation

/// Status of a gated feature
enum GateStatus: Equatable {
    case unlocked
    case lockedTrialNotStarted
    case lockedTrialExpired
    case lockedPremiumOnly
}