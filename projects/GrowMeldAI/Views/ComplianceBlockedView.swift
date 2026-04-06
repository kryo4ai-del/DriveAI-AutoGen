@main

// MARK: - Compliance Gate with Blocking Logic
class ComplianceGate: ObservableObject {
    static let shared = ComplianceGate()
    
    @Published var hasLegalClearance = false
    @Published var isCheckingCompliance = true
    @Published var clearanceCheckDate: Date?
    @Published var missingRequirements: [ComplianceRequirement] = []
    
    private let complianceChecklistPath = "ComplianceChecklist"
    
    @MainActor
    func checkLegalStatus() async {
        defer { isCheckingCompliance = false }
        
        guard let checklistData = loadComplianceChecklist() else {
            missingRequirements = ComplianceRequirement.allCases
            hasLegalClearance = false
            return
        }
        
        hasLegalClearance = checklistData.allRequirementsMet
        clearanceCheckDate = checklistData.signoffDate
        missingRequirements = checklistData.missingRequirements
        
        // Log for audit trail
        ComplianceLogger.shared.log(
            event: .complianceCheckCompleted,
            details: ["gatePassed": hasLegalClearance]
        )
    }
    
    private func loadComplianceChecklist() -> ComplianceChecklistData? {
        guard let path = Bundle.main.path(forResource: complianceChecklistPath, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let checklist = try? JSONDecoder().decode(ComplianceChecklistData.self, from: data)
        else {
            return nil
        }
        return checklist
    }
}

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

enum ComplianceRequirement: String, CaseIterable {
    case questionCatalogLicense = "Question Catalog License Verification"
    case privacyPolicy = "GDPR-Compliant Privacy Policy"
    case termsOfService = "Terms of Service with Exam Disclaimer"
    case gdprCompliance = "GDPR Compliance Review"
}

struct ComplianceBlockedView: View {
    let clearanceCheckDate: Date?
    let requirementsMissing: [ComplianceRequirement]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundColor(.red)
            
            Text("Compliance Review erforderlich")
                .font(.headline)
                .accessibilityLabel("App ist gesperrt wegen ausstehender Compliance-Überprüfung")
            
            Text("Die Anwendung wartet auf die rechtliche Freigabe durch unseren legal team.")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ausstehende Anforderungen:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(requirementsMissing, id: \.self) { requirement in
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(requirement.rawValue)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            if let checkDate = clearanceCheckDate {
                Text("Zuletzt überprüft: \(checkDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Compliance-Status aktualisieren") {
                Task {
                    await ComplianceGate.shared.checkLegalStatus()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}