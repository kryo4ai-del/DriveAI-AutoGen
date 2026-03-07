import SwiftUI

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isScanning {
                    Text("Scanning...")
                        .font(.largeTitle)
                } else {
                    Button(action: {
                        viewModel.startScanning()
                    }) {
                        Text("Start Scan")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                List(viewModel.scannedDocuments) { document in
                    NavigationLink(destination: ScannedDocumentView(document: document)) {
                        Text(document.text)
                    }
                }
            }
            .padding()
            .navigationTitle("OCR Scanner")
        }
    }
}