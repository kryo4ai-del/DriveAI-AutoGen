// Features/COPPA/Views/AgeGateRejectionView.swift
import SwiftUI

struct AgeGateRejectionView: View {
    @ObservedObject var viewModel: AgeGateViewModel

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Fast geschafft!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Du musst mindestens 16 Jahre alt sein, um die App zu nutzen.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: viewModel.retryAgeEntry) {
                Text("Erneut versuchen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}