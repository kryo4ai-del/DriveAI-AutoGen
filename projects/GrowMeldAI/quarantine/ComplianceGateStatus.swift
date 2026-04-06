// Create formal gate mechanism:
// File: compliance/compliance_gate.swift

enum ComplianceGateStatus {
  case pending           // Awaiting legal review
  case approved          // Legal signed off
  case approvedWithWaivers(waivers: [String])
  case rejected(reason: String)
  case blocked          // Can't proceed until resolved
}

struct ComplianceGateCertificate {
  let status: ComplianceGateStatus
  let reviewedBy: String
  let reviewDate: Date
  let expiryDate: Date  // Refresh periodically
  let domains: [String] // privacy, copyright, regulated_domain, ai_disclosure, app_store
  let signatureHash: String  // Legal counsel digital signature
}

// Before T-DEVOPS-003:
guard let cert = loadComplianceCertificate(),
      case .approved = cert.status,
      cert.reviewDate <= Date(),
      cert.expiryDate >= Date() else {
  fatalError("❌ Compliance gate not cleared. Cannot upload to TestFlight.")
}