import SwiftUI

struct DataExportConfirmationView: View {
    @ObservedObject var viewModel: ComplianceViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isExporting {
                ProgressView("Exportiere deine Daten...")
            } else if let url = viewModel.exportedDataURL {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.green)

                    Text("Daten erfolgreich exportiert")
                        .font(.headline)

                    ShareLink(item: url) {
                        Label("In Dateien speichern", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let error = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.red)

                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Button("Erneut versuchen") {
                        Task { await viewModel.exportData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Button("Fertig") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}