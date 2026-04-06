// MARK: - App/DriveAIApp.swift
import SwiftUI

@main

// MARK: - Compliance Gate Controller
@MainActor
class ComplianceGate: ObservableObject {
    static let shared = ComplianceGate()
    
    @Published var hasLegalClearance = false
    @Published var isCheckingCompliance = true
    @Published var clearanceCheckDate: Date?
    @Published var missingRequirements: [ComplianceRequirement] = []
    
    private let complianceChecklistFilename = "ComplianceChecklist"
    
    nonisolated init() {}
    
    func checkLegalStatus() async {
        defer { 
            DispatchQueue.main.async {
                self.isCheckingCompliance = false
            }
        }
        
        guard let checklist = loadComplianceChecklist() else {
            DispatchQueue.main.async {
                self.hasLegalClearance = false
                self.missingRequirements = ComplianceRequirement.allCases
            }
            ComplianceLogger.shared.log(
                event: .complianceCheckFailed,
                details: ["reason": "Checklist file not found"]
            )
            return
        }
        
        DispatchQueue.main.async {
            self.hasLegalClearance = checklist.allRequirementsMet
            self.clearanceCheckDate = checklist.signoffDate
            self.missingRequirements = checklist.missingRequirements
            
            ComplianceLogger.shared.log(
                event: .complianceCheckCompleted,
                details: ["gatePassed": checklist.allRequirementsMet]
            )
        }
    }
    
    private func loadComplianceChecklist() -> ComplianceChecklistData? {
        guard let path = Bundle.main.path(forResource: complianceChecklistFilename, ofType: "json") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let decoded = try? JSONDecoder().decode(ComplianceChecklistData.self, from: data) else {
            return nil
        }
        
        return decoded
    }
}

// MARK: - Compliance Checklist Data Model
struct ComplianceChecklistData: Codable {
    let questionCatalogLicenseVerified: Bool
    let privacyPolicyApproved: Bool
    let termsOfServiceApproved: Bool
    let gdprComplianceReviewed: Bool
    let signoffDate: Date?
    let legalCounselName: String?
    let legalCounselJurisdiction: String?
    
    var allRequirementsMet: Bool {
        questionCatalogLicenseVerified &&
        privacyPolicyApproved &&
        termsOfServiceApproved &&
        gdprComplianceReviewed &&
        signoffDate != nil &&
        legalCounselName != nil
    }
    
    var missingRequirements: [ComplianceRequirement] {
        var missing: [ComplianceRequirement] = []
        if !questionCatalogLicenseVerified { missing.append(.questionCatalogLicense) }
        if !privacyPolicyApproved { missing.append(.privacyPolicy) }
        if !termsOfServiceApproved { missing.append(.termsOfService) }
        if !gdprComplianceReviewed { missing.append(.gdprCompliance) }
        return missing
    }
}

enum ComplianceRequirement: String, CaseIterable, Identifiable {
    case questionCatalogLicense = "Fragenkatalog-Lizenz"
    case privacyPolicy = "Datenschutzrichtlinie (GDPR)"
    case termsOfService = "Nutzungsbedingungen"
    case gdprCompliance = "GDPR-Compliance-Überprüfung"
    
    var id: String { self.rawValue }
}

// MARK: - Compliance Checking View
struct ComplianceCheckingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Compliance-Status wird überprüft...")
                .font(.headline)
            
            Text("Bitte warten Sie, während die rechtliche Freigabe überprüft wird.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Compliance Blocked View