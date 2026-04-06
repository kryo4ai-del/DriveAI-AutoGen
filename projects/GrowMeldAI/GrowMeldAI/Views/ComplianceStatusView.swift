// File: ComplianceStatusView.swift
import SwiftUI

struct ComplianceStatusView: View {
    @StateObject var viewModel = ComplianceViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.shield")
                    .font(.title)
                Text("Compliance Status")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Regulatory Scope")
                    .font(.headline)
                Text(viewModel.decisionLog.regulatoryScope.rawValue.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Content Licensing")
                    .font(.headline)
                Text(viewModel.decisionLog.contentLicensing.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Data Architecture")
                    .font(.headline)
                Text(viewModel.decisionLog.dataArchitecture.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)

            Spacer()

            Button(action: {
                viewModel.isShowingDecisionSheet = true
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Update Compliance Settings")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .navigationTitle("DriveAI Compliance")
        .sheet(isPresented: $viewModel.isShowingDecisionSheet) {
            ComplianceDecisionView(viewModel: viewModel)
        }
    }
}