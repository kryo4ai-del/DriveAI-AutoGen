// Views/Location/LocationFilterView.swift
import SwiftUI

struct LocationFilterView: View {
    @StateObject private var viewModel: LocationFilterViewModel
    @Environment(\.accessibilityEnabled) var a11yEnabled
    @Environment(\.dynamicTypeSize) var typeSize
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingStateView()
                } else if let error = viewModel.error {
                    ErrorStateView(error: error, onRetry: viewModel.requestLocation)
                } else {
                    regionListView
                }
            }
            .navigationTitle("Bundesland wählen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var regionListView: some View {
        List {
            // Favorites Section
            if !viewModel.favoriteRegions.isEmpty {
                Section("Deine Bundesländer") {
                    ForEach(viewModel.favoriteRegions) { region in
                        RegionRowView(
                            region: region,
                            isFavorite: true,
                            isSelected: viewModel.selectedRegion?.id == region.id,
                            onSelect: { selectRegion(region) },
                            onToggleFavorite: { viewModel.toggleFavorite(region) }
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityHint("Tippe zum Wählen, oder schiebe nach links zum Entfernen")
                    }
                }
            }
            
            // All Regions Section
            Section("Alle Bundesländer") {
                ForEach(viewModel.allRegions) { region in
                    RegionRowView(
                        region: region,
                        isFavorite: region.isFavorite,
                        isSelected: viewModel.selectedRegion?.id == region.id,
                        onSelect: { selectRegion(region) },
                        onToggleFavorite: { viewModel.toggleFavorite(region) }
                    )
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func selectRegion(_ region: PLZRegion) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        viewModel.selectedRegion = region
    }
}

#Preview {
    LocationFilterView(
        viewModel: .init(
            locationService: MockLocationService(),
            dataService: MockDataService()
        )
    )
}