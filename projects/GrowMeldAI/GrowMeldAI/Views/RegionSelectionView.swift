struct RegionSelectionView: View {
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack {
            Picker("Region", selection: $regionManager.selectedRegion) {
                ForEach(Region.allCases, id: \.self) { region in
                    Text(region.displayName).tag(region)
                }
            }
            .onChange(of: regionManager.selectedRegion) { newRegion in
                // ✅ Filter language options to supported languages for this region
                regionManager.setRegion(newRegion)
                // Now regionManager validates language compatibility
            }
            
            // ✅ NEW: Show only supported languages for selected region
            if regionManager.selectedRegion == .canada {
                Picker("Language", selection: $localizationManager.currentLanguage) {
                    Text("English").tag(LocalizationManager.Language.english)
                    Text("Français").tag(LocalizationManager.Language.french)
                }
            } else if regionManager.selectedRegion == .australia {
                Text("English") // Australia only supports English
            }
        }
    }
}