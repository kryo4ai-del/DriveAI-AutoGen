import Foundation
import Combine

class BlocklistViewModel: ObservableObject {
    @Published var blocklistItems: [BlocklistItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadBlocklist() {
        isLoading = true
        simulateLoadingData()
    }

    private func simulateLoadingData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulating success scenario
            self.blocklistItems = [
                BlocklistItem(id: UUID(), question: "Was bedeutet ein rotes Licht?", reason: "Verkehrssignale"),
                BlocklistItem(id: UUID(), question: "Was ist die Geschwindigkeitsbegrenzung in Wohngebieten?", reason: "Allgemeine Regeln")
            ]
            self.isLoading = false
            
            // Uncomment to simulate an error
            // self.errorMessage = "Fehler beim Laden der Blockliste"
        }
    }
}