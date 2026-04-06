import SwiftUI
struct DataExportConfirmationView: View {
    @ObservedObject var viewModel: ComplianceViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView("Exportiere deine Daten...")
            } else if let url = viewModel.exportedDataURL {
                // SUCCESS: Show share options
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("Daten erfolgreich exportiert")
                        .font(.headline)
                    
                    // Share button
                    ShareLink(item: url) {
                        Label("In Dateien speichern", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let error = viewModel.errorMessage {
                // FAILURE: Show retry option
                ErrorRecoveryView(
                    message: error,
                    retryAction: { Task { await viewModel.exportData() } }
                )
            }
            
            Button("Fertig") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}