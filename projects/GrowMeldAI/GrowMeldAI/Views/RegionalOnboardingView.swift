import SwiftUI

struct RegionalOnboardingView: View {
    @StateObject private var viewModel: RegionalOnboardingViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: RegionalOnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your Region")
                .font(.title)
                .fontWeight(.bold)

            Text("Select your location to get questions tailored to your local driving rules")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Picker("Region", selection: $viewModel.selectedRegion) {
                ForEach(Region.allCases) { region in
                    Text("\(region.flagEmoji) \(region.displayName)")
                        .tag(region)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            if viewModel.selectedRegion != viewModel.regionalConfigService.currentRegion {
                Button("Continue") {
                    Task {
                        do {
                            try await viewModel.saveRegion()
                            dismiss()
                        } catch {
                            print("Failed to save region: \(error)")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
        .navigationTitle("Region Selection")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}