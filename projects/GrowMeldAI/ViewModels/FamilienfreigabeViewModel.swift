@MainActor
class FamilienfreigabeViewModel: ObservableObject {
    private let dataService: LocalDataService
    
    init(parentEmail: String = "", dataService: LocalDataService = LocalDataService.shared) {
        self.dataService = dataService
        self.setup = FamilienfreigabeSetup(parentEmail: parentEmail)
        loadExistingSetup()
    }
    
    private func persistSetup() async throws {
        do {
            try await dataService.saveFamilienfreigabeSetup(setup)
            // Emit success via published property for UI feedback
            DispatchQueue.main.async {
                self.error = nil
            }
        } catch {
            throw FamilienfreigabeError.persistenceFailed(error.localizedDescription)
        }
    }
    
    private func loadExistingSetup() {
        Task {
            do {
                if let existingSetup = try await dataService.loadFamilienfreigabeSetup() {
                    DispatchQueue.main.async {
                        self.setup = existingSetup
                    }
                }
            } catch {
                print("⚠️ Failed to load existing setup: \(error)")
            }
        }
    }
    
    func completeSetup() async {
        isLoading = true
        defer { isLoading = false }
        
        guard !setup.childAccounts.isEmpty else {
            error = "Bitte fügen Sie mindestens ein Kind hinzu"
            return
        }
        
        guard consentAgreed else {
            error = "Bitte akzeptieren Sie die Datenschutzbedingungen"
            return
        }
        
        do {
            setup.isActive = true
            setup.lastModifiedAt = Date()
            try await persistSetup()  // ← Now awaits real persistence
            error = nil
        } catch let error as FamilienfreigabeError {
            self.error = error.userMessage
        } catch {
            self.error = "Unerwarteter Fehler: \(error.localizedDescription)"
        }
    }
}

enum FamilienfreigabeError: LocalizedError {
    case persistenceFailed(String)
    case invalidEmail
    case childAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .persistenceFailed(let msg):
            return "Speichern fehlgeschlagen: \(msg)"
        case .invalidEmail:
            return "Ungültige E-Mail-Adresse"
        case .childAlreadyExists:
            return "Dieses Kind wurde bereits hinzugefügt"
        }
    }
    
    var userMessage: String {
        self.localizedDescription
    }
}