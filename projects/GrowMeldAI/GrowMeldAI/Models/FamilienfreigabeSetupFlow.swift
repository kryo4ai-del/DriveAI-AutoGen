import SwiftUI

struct FamilienfreigabeSetupFlow: View {
    @ObservedObject var viewModel: FamilienfreigabeViewModel

    var body: some View {
        NavigationStack {
            setupStepView
                .navigationTitle(viewModel.setupStep.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if viewModel.setupStep != .welcome {
                            Button("Zurück") {
                                viewModel.goBackInSetup()
                            }
                            .accessibilityIdentifier("setup.back.button")
                        }
                    }
                }
        }
        .environment(\.sizeCategory, viewModel.preferredContentSizeCategory)
    }

    @ViewBuilder
    private var setupStepView: some View {
        switch viewModel.setupStep {
        case .welcome:
            FamilienfreigabeWelcomeView(viewModel: viewModel)
        case .addChild:
            FamilienfreigabeAddChildView(viewModel: viewModel)
        case .selectPermissions:
            PermissionSelectionView(viewModel: viewModel)
        case .reviewConsent:
            ConsentReviewView(viewModel: viewModel)
        case .confirmation:
            FamilienfreigabeConfirmationView(viewModel: viewModel)
        }
    }
}