@MainActor
final class LocationSelectionViewModel: ObservableObject {
    @Published var suggestions: [PostalCode] = []
    @Published var suggestionsAriaLive: String = ""  // ✅ New: for live region announcement
    
    func updateSearchText(_ text: String) {
        searchTask?.cancel()
        
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            suggestions = []
            suggestionsAriaLive = ""
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            guard !Task.isCancelled else { return }
            
            let results = await locationDataService.postalCodes(matching: trimmed, limit: 5)
            
            guard !Task.isCancelled else { return }
            
            self.suggestions = results
            
            // ✅ Announce to VoiceOver: "X results found"
            self.suggestionsAriaLive = "\(results.count) Postleitzahlenvorschläge für '\(trimmed)' gefunden."
        }
    }
}