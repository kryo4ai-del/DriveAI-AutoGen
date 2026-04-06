// PlantResultView.swift
import SwiftUI

struct PlantResultView: View {
    let plant: Plant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(plant.scientificName)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Erkennungssicherheit: \(Int(plant.confidence * 100))%")
                    .font(.headline)

                Divider()

                Text("Beschreibung")
                    .font(.headline)

                Text(plant.description)
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Pflanzeninfo")
        .navigationBarTitleDisplayMode(.inline)
    }
}