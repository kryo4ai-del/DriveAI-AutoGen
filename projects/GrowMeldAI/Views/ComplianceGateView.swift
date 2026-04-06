import SwiftUI

@main

struct ComplianceGateView: View {
    @StateObject var viewModel: AgeGatingViewModel
    @State private var regime: ComplianceRegime = .coppaAndGdpr

    init(complianceService: ComplianceService) {
        _viewModel = StateObject(wrappedValue: AgeGatingViewModel(complianceService: complianceService))
    }

    var body: some View {
        NavigationView {
            AgeVerificationScreen(viewModel: viewModel, regime: regime)
                .task {
                    regime = await viewModel.complianceService.determineRegime()
                }
                .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK", role: .cancel) { viewModel.errorMessage = nil }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
        }
    }
}