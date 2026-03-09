import SwiftUI

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()

    var body: some View {
        VStack {
            if viewModel.isScanning {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("Scanning...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button("Cancel") { viewModel.cancelScanning() }
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
            } else {
                Button(action: { viewModel.startScanning() }) {
                    Label("Start Scan", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding([.horizontal, .top])
            }

            if viewModel.scannedDocuments.isEmpty && !viewModel.isScanning {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No scans yet.")
                        .font(.headline)
                    Text("Tap Start Scan to scan a question.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                Spacer()
            } else if !viewModel.scannedDocuments.isEmpty {
                List(viewModel.scannedDocuments) { document in
                    NavigationLink(destination: ScannedDocumentView(document: document)) {
                        Text(document.text)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Scan Question")
    }
}
