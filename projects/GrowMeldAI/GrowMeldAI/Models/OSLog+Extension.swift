// UserProfileService.swift
import Foundation
import os.log

/// Manages user profile persistence and state with thread-safe access
@globalActor

extension OSLog {
    static let `default` = OSLog(subsystem: "com.driveai.profile", category: "persistence")
}