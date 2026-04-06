// File: ComplianceViewModel.swift
import Foundation
import Combine

@MainActor
final class ComplianceViewModel: ObservableObject {
    @Published var decisionLog: ComplianceDecisionLog
    @Published var isShowingDecisionSheet = false
    @Published var selectedDecisionType: DecisionType = .regulatoryScope

    enum DecisionType {
        case regulatoryScope
        case contentLicensing
        case dataArchitecture
        case legalPathway
    }

    init(initialLog: ComplianceDecisionLog = ComplianceDecisionLog()) {
        self.decisionLog = initialLog
    }

    // MARK: - Decision Handlers

    func updateRegulatoryScope(_ scope: ComplianceDecisionLog.RegulatoryScope) {
        decisionLog.regulatoryScope = scope
        validateCompliance()
    }

    func updateContentLicensing(_ model: ComplianceDecisionLog.ContentLicensingModel) {
        decisionLog.contentLicensing = model
        validateCompliance()
    }

    func updateDataArchitecture(_ model: ComplianceDecisionLog.DataArchitectureModel) {
        decisionLog.dataArchitecture = model
        validateCompliance()
    }

    func updateLegalPathway(_ pathway: String) {
        decisionLog.legalApprovalPathway = pathway
    }

    private func validateCompliance() {
        // Additional validation logic can be added here
        objectWillChange.send()
    }

    // MARK: - Compliance Status

    var complianceStatus: String {
        decisionLog.isComplianceReady ? "✅ Compliance Ready" : "⚠️ Pending Decisions"
    }

    var complianceColor: String {
        decisionLog.isComplianceReady ? "green" : "orange"
    }
}