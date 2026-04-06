import SwiftUI

struct EmptyMaintenanceStateView: View {
    let coverage: Double
    let message: String

    var body: some View {
        VStack(spacing: DriveAISpacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(DriveAIColors.success)

            VStack(spacing: DriveAISpacing.sm) {
                Text("Alles auf dem Laufenden!")
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(DriveAISpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}