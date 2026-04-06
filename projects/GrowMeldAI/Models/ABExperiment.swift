// Services/ABTesting/ABTestingService.swift

import Foundation

/// Thread-safe A/B testing service using actor isolation

// MARK: - Models

struct ABExperiment: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let control: String
    let variants: [ABVariant]
    let createdAt: Date
    let endsAt: Date?
    
    var isActive: Bool {
        let now = Date()
        return now >= createdAt && (endsAt == nil || now < endsAt!)
    }
}

struct ABVariant: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let weight: Int // 0-100
    let impact: String? // e.g., "+12% completion rate"
}

// MARK: - Metadata Handling

/// Universal wrapper for heterogeneous Codable types

// MARK: - Error Handling

// MARK: - Logging

class ABTestingLogger: Sendable {
    static let shared = ABTestingLogger()
    
    private let queue = DispatchQueue(
        label: "com.driveai.abtesting.logger",
        attributes: .concurrent
    )
    
    func log(_ message: String) {
        #if DEBUG
        queue.async {
            print("[ABTesting] ✓ \(message)")
        }
        #endif
    }
    
    func warn(_ message: String) {
        queue.async {
            print("[ABTesting] ⚠ WARNING: \(message)")
        }
    }
    
    func error(_ message: String) {
        queue.async {
            print("[ABTesting] ✗ ERROR: \(message)")
        }
    }
}