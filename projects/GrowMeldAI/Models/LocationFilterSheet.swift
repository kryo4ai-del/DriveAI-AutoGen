struct LocationFilterSheet: View {
    @State var searchText = ""
    @FocusState var focusedField: Field?
    
    enum Field {
        case searchBar
        case regionList
    }
    
    var body: some View {
        VStack {
            // 1. Search (focused first)
            SearchBar(text: $searchText)
                .focused($focusedField, equals: .searchBar)
                .accessibilityLabel("Nach Region suchen")
                .accessibilityHint("Geben Sie einen Bundesland-Namen oder eine Postleitzahl ein")
            
            // 2. Results
            List(filteredRegions) { region in
                Button(action: { selectRegion(region) }) {
                    HStack {
                        Text(region.localizedName)
                        
                        if isFavorite(region) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .accessibilityLabel(region.localizedName)
                .accessibilityValue(isFavorite(region) ? "Favorit" : "")
                .accessibilityHint("Doppeltippen zum Auswählen")
            }
            .focused($focusedField, equals: .regionList)
            
            // 3. Confirm (focus last)
            Button("Bestätigen") { dismiss() }
                .accessibilityLabel("Bestätigen")
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .onAppear {
            focusedField = .searchBar  // Start at search
        }
    }
}