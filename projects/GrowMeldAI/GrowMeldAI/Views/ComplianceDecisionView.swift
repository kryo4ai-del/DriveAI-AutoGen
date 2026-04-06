// File: ComplianceDecisionView.swift
import SwiftUI

struct ComplianceDecisionView: View {
    @StateObject var viewModel: ComplianceViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Regulatory Scope")) {
                    Picker("Primary Regulation", selection: $viewModel.decisionLog.regulatoryScope) {
                        ForEach(ComplianceDecisionLog.RegulatoryScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue.uppercased()).tag(scope)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Content Licensing")) {
                    Picker("Licensing Model", selection: $viewModel.decisionLog.contentLicensing) {
                        ForEach(ComplianceDecisionLog.ContentLicensingModel.allCases, id: \.self) { model in
                            Text(model.rawValue.capitalized).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Data Architecture")) {
                    Picker("Data Model", selection: $viewModel.decisionLog.dataArchitecture) {
                        ForEach(ComplianceDecisionLog.DataArchitectureModel.allCases, id: \.self) { model in
                            Text(model.rawValue.capitalized).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Legal Approval")) {
                    TextField("Approval Pathway", text: $viewModel.decisionLog.legalApprovalPathway)
                        .autocapitalization(.words)
                }

                Section {
                    HStack {
                        Spacer()
                        Text(viewModel.complianceStatus)
                            .foregroundColor(viewModel.complianceColor == "green" ? .green : .orange)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Compliance Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
}