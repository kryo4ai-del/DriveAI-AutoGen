// Views/PlantDetailView.swift
import SwiftUI

struct PlantDetailView: View {
    @State var plant: Plant
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                plantImageSection

                VStack(alignment: .leading, spacing: 12) {
                    Text(plant.name)
                        .font(.largeTitle.bold())

                    Text(plant.scientificName)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    difficultyIndicator

                    Divider()

                    originSection

                    Divider()

                    descriptionSection

                    Divider()

                    careSection

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PlantEditView(plant: $plant)
                .presentationDetents([.medium, .large])
        }
    }

    private var plantImageSection: some View {
        Group {
            if let imageName = plant.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
            } else {
                Color.gray.opacity(0.2)
                    .frame(height: 250)
                    .overlay {
                        VStack {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                            Text("No image available")
                                .foregroundColor(.secondary)
                        }
                    }
            }
        }
    }

    private var difficultyIndicator: some View {
        HStack {
            Text("Difficulty:")
            Spacer()
            HStack(spacing: 2) {
                ForEach(1..<6) { index in
                    Image(systemName: index <= plant.difficulty ? "star.fill" : "star")
                        .foregroundColor(index <= plant.difficulty ? .yellow : .gray)
                }
            }
        }
    }

    private var originSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Origin")
                .font(.headline)
            Text(plant.origin)
                .font(.body)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            Text(plant.description)
                .font(.body)
        }
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Care Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "drop.fill")
                    Text("Watering: \(plant.wateringFrequency)")
                }

                HStack {
                    Image(systemName: "sun.max.fill")
                    Text("Sunlight: \(plant.sunlightRequirements)")
                }
            }
            .font(.subheadline)
        }
    }
}