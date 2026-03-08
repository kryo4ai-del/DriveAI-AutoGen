func loadBlocklist() {
    isLoading = true
    // Simulate loading data (Replace this with actual data fetching logic)
    simulateLoadingData()
}

private func simulateLoadingData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        // Add successful data loading or error scenario here
    }
}

// ---

List(viewModel.blocklistItems) { item in
    BlocklistItemView(item: item)
}

// ---

func loadBlocklist() {
    isLoading = true
    simulateLoadingData()
}

private func simulateLoadingData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        // Simulating success scenario
        self.blocklistItems = [...]
        self.isLoading = false
        
        // Uncomment to simulate an error
        // self.errorMessage = "Fehler beim Laden der Blockliste"
    }
}

// ---

func simulateLoadingError() {
    isLoading = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.errorMessage = "Fehler beim Laden der Blockliste"
        self.isLoading = false
    }
}