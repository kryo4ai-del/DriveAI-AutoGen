// File: ComplianceDecisionLog.swift
import Foundation

/// Centralized decision log for all compliance-related decisions
/// This serves as the single source of truth for regulatory decisions
struct ComplianceDecisionLog: Codable, Hashable {
    // MARK: - Regulatory Scope Decisions

    enum RegulatoryScope: String, Codable, CaseIterable {
        case gdpd // GDPR/DSGVO (primary)
        case appleAppStore
        case germanEducationLaw
        case other
    }

    // MARK: - Content Licensing Models

    enum ContentLicensingModel: String, Codable, CaseIterable {
        case officialTUV
        case dekraPartnership
        case asuCatalog
        case customContent
        case none
    }

    // MARK: - Data Architecture Models

    enum DataArchitectureModel: String, Codable, CaseIterable {
        case offlineOnly
        case cloudSyncPlanned
        case hybrid
    }

    // MARK: - Properties

    var regulatoryScope: RegulatoryScope = .gdpd
    var contentLicensing: ContentLicensingModel = .none
    var dataArchitecture: DataArchitectureModel = .offlineOnly
    var legalApprovalPathway: String = "inHouseReview"
    var decisionDate: Date = Date()
    var decisionMaker: String = "ProductLead"

    // MARK: - Computed Properties

    var isComplianceReady: Bool {
        regulatoryScope != .other &&
        contentLicensing != .none &&
        dataArchitecture != .hybrid // Hybrid requires additional legal review
    }

    var complianceSummary: String {
        """
        Regulatory Scope: \(regulatoryScope.rawValue.uppercased())
        Content Licensing: \(contentLicensing.rawValue)
        Data Architecture: \(dataArchitecture.rawValue)
        Legal Pathway: \(legalApprovalPathway)
        Compliance Ready: \(isComplianceReady ? "YES" : "NO")
        """
    }
}