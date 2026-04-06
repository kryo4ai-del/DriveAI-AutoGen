struct PlantLibraryView: View {
    @StateObject private var viewModel = PlantLibraryViewModel()
    
    var body: some View {
        List(viewModel.filteredPlants) { plant in
            NavigationLink(destination: PlantDetailView(plant: plant)) {
                Text(plant.germanName)  // ❌ No distinction between German/scientific name
                Text(plant.scientificName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .searchable(
            text: $viewModel.searchText,
            prompt: "Pflanze suchen"
            // ❌ No accessibility hints for search
        )
    }
}