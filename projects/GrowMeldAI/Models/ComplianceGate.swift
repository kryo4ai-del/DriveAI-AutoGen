// ComplianceGate.swift
import Foundation
import Combine

final class ComplianceGate: ObservableObject {
    // MARK: - Singleton with thread safety
    static let shared = ComplianceGate()

    private init() {
        // Private initializer prevents external instantiation
    }

    // MARK: - Published Properties
    @Published var hasLegalClearance: Bool = false
    @Published var isCheckingCompliance: Bool = true
    @Published var clearanceCheckDate: Date?
    @Published var missingRequirements: [ComplianceRequirement] = []

    // MARK: - State Management
    private var complianceCheckTask: Task<Void, Never>?

    // MARK: - Compliance Check
    func checkLegalStatus() async {
        // Cancel any ongoing check
        complianceCheckTask?.cancel()

        complianceCheckTask = Task { @MainActor in
            defer { isCheckingCompliance = false }

            isCheckingCompliance = true
            hasLegalClearance = false
            missingRequirements = []

            do {
                try await performComplianceCheck()
            } catch {
                logComplianceError(error)
                missingRequirements = [.legalClearance]
            }
        }
    }

    private func performComplianceCheck() async throws {
        // Simulate async compliance check
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // In production, this would check:
        // 1. Privacy policy acceptance
        // 2. Terms of service acceptance
        // 3. Regulatory compliance (DACH region)
        // 4. Question catalog licensing

        // For now, we'll simulate successful clearance
        hasLegalClearance = true
        clearanceCheckDate = Date()
    }

    private func logComplianceError(_ error: Error) {
        // In production: log to analytics service
        print("Compliance check failed: \(error.localizedDescription)")
    }

    // MARK: - Context Reset (FK-004 compliance)
    func resetContext() {
        complianceCheckTask?.cancel()
        hasLegalClearance = false
        isCheckingCompliance = false
        clearanceCheckDate = nil
        missingRequirements = []
    }
}

// MARK: - Compliance Models
enum ComplianceRequirement: String, CaseIterable, Identifiable {
    case legalClearance
    case privacyPolicyAccepted
    case termsOfServiceAccepted
    case questionCatalogVerified

    var id: String { rawValue }
}

struct ComplianceChecklistData: Codable {
    let version: String
    let requirements: [ComplianceRequirement]
    let lastUpdated: Date
}