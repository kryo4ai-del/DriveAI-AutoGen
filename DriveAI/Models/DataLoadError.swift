@Published var dataLoadError: DataLoadError?

private func loadResults() {
    guard let data = userDefaults.data(forKey: resultsKey) else {
        allResults = []
        dataLoadError = nil
        return
    }
    
    do {
        decoder.dateDecodingStrategy = .iso8601
        allResults = try decoder.decode([SimulationResult].self, from: data)
        dataLoadError = nil
    } catch let error as DecodingError {
        #if DEBUG
        print("❌ Decode error: \(error)")
        #endif
        
        self.dataLoadError = .decodingFailed(error)
        allResults = []
        
        // Optional: attempt migration or backup restore
        attemptRecovery()
    } catch {
        self.dataLoadError = .unknown(error)
        allResults = []
    }
}

enum DataLoadError: LocalizedError {
    case decodingFailed(DecodingError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "Deine Ergebnisse konnten nicht geladen werden. Sie könnten beschädigt sein."
        case .unknown(let e):
            return "Fehler beim Laden: \(e.localizedDescription)"
        }
    }
}

private func attemptRecovery() {
    // Try to restore from backup, if available
    // Or notify analytics
}