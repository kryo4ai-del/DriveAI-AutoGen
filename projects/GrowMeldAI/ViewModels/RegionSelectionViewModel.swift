@MainActor
class RegionSelectionViewModel: ObservableObject {
    @Published var selectedCountry: Country?
    @Published var selectedRegion: Region?
    // ❌ NO loading state, error state, or data fetching
    // ❌ Country.regions is a computed property with NO validation
    
    var isFormValid: Bool {
        selectedCountry != nil && selectedRegion != nil
    }
}