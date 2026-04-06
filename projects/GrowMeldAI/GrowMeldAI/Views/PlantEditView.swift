// Views/PlantEditView.swift
import SwiftUI

struct PlantEditView: View {
    @Binding var plant: Plant
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var scientificName: String
    @State private var origin: String
    @State private var difficulty: Int
    @State private var description: String
    @State private var careInstructions: String
    @State private var wateringFrequency: String
    @State private var sunlightRequirements: String

    init(plant: Binding<Plant>) {
        self._plant = plant
        self._name = State(initialValue: plant.wrappedValue.name)
        self._scientificName = State(initialValue: plant.wrappedValue.scientificName)
        self._origin = State(initialValue: plant.wrappedValue.origin)
        self._difficulty = State(initialValue: plant.wrappedValue.difficulty)
        self._description = State(initialValue: plant.wrappedValue.description)
        self._careInstructions = State(initialValue: plant.wrappedValue.careInstructions)
        self._wateringFrequency = State(initialValue: plant.wrappedValue.wateringFrequency)
        self._sunlightRequirements = State(initialValue: plant.wrappedValue.sunlightRequirements)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Scientific Name", text: $scientificName)
                    TextField("Origin", text: $origin)
                }

                Section(header: Text("Difficulty")) {
                    Stepper("\(difficulty)/5", value: $difficulty, in: 1...5)
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section(header: Text("Care Instructions")) {
                    TextEditor(text: $careInstructions)
                        .frame(minHeight: 100)
                    TextField("Watering Frequency", text: $wateringFrequency)
                    TextField("Sunlight Requirements", text: $sunlightRequirements)
                }
            }
            .navigationTitle("Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updatePlant()
                        dismiss()
                    }
                    .disabled(name.isEmpty || scientificName.isEmpty)
                }
            }
        }
    }

    private func updatePlant() {
        plant.name = name
        plant.scientificName = scientificName
        plant.origin = origin
        plant.difficulty = difficulty
        plant.description = description
        plant.careInstructions = careInstructions
        plant.wateringFrequency = wateringFrequency
        plant.sunlightRequirements = sunlightRequirements
    }
}