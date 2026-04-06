// Views/PlantProfileView.swift
import SwiftUI

struct PlantProfileView: View {
    @State private var viewModel = PlantProfileViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading plants...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error, onRetry: { Task { await viewModel.loadPlants() } })
                } else {
                    plantListView
                }
            }
            .navigationTitle("Plant Profiles")
            .task { await viewModel.loadPlants() }
        }
    }

    private var plantListView: some View {
        List(viewModel.plants) { plant in
            NavigationLink(value: plant) {
                PlantRow(plant: plant)
            }
        }
        .navigationDestination(for: Plant.self) { plant in
            PlantDetailView(plant: plant)
        }
        .refreshable {
            await viewModel.loadPlants()
        }
    }
}

struct PlantRow: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 12) {
            if let imageName = plant.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                Text(plant.scientificName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text("Difficulty: \(plant.difficulty)/5")
                    Spacer()
                    Text("From: \(plant.origin)")
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}
