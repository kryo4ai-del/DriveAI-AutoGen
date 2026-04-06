// ViewModels/PlantProfileViewModel.swift
import Foundation
import SwiftUI

@MainActor
@Observable
class PlantProfileViewModel {
    private(set) var plants: [Plant] = []
    private(set) var selectedPlant: Plant?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let dataService: PlantDataServiceProtocol

    init(dataService: PlantDataServiceProtocol = LocalPlantDataService()) {
        self.dataService = dataService
    }

    func loadPlants() async {
        isLoading = true
        errorMessage = nil

        do {
            plants = try await dataService.fetchAllPlants()
        } catch {
            errorMessage = "Failed to load plants: \(error.localizedDescription)"
            print("Error loading plants: \(error)")
        }

        isLoading = false
    }

    func selectPlant(_ plant: Plant) {
        selectedPlant = plant
    }

    func updatePlant(_ plant: Plant) async throws {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else {
            throw PlantError.plantNotFound
        }

        plants[index] = plant
        try await dataService.savePlant(plant)
    }
}

enum PlantError: Error {
    case plantNotFound
    case invalidData
}

protocol PlantDataServiceProtocol {
    func fetchAllPlants() async throws -> [Plant]
    func fetchPlant(id: UUID) async throws -> Plant?
    func savePlant(_ plant: Plant) async throws
    func deletePlant(_ plant: Plant) async throws
}