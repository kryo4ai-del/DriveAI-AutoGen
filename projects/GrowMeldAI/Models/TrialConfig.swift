// TrialConfig.swift
import Foundation

/// Configuration for trial behavior
struct TrialConfig: Codable {
    let durationDays: Int
    let maxTrialsPerDevice: Int
    let trialResetCooldownHours: Int

    static let `default` = TrialConfig(
        durationDays: 7,
        maxTrialsPerDevice: 1,
        trialResetCooldownHours: 24
    )
}