import SwiftUI
import Combine

class ScannerViewModel: ObservableObject {
    @Published var scannedDocuments: [ScannedDocument] = []
    @Published var isScanning: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let ocrService = OCRService()
    
    func startScanning() {
        isScanning = true
        // You would typically trigger camera scanning logic here
    }

    func cancelScanning() {
        isScanning = false
    }
    
    func handleScanResult(text: String) {
        let document = ScannedDocument(text: text)
        scannedDocuments.append(document)
        saveToLocalDatabase(document)
        isScanning = false
    }
    
    private func saveToLocalDatabase(_ document: ScannedDocument) {
        // Implement local storage logic (e.g., saving to UserDefaults or a local database)
    }
    
    func clearScans() {
        scannedDocuments.removeAll()
    }
}