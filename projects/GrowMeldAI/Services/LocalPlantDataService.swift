// Services/LocalPlantDataService.swift
import Foundation

class LocalPlantDataService: PlantDataServiceProtocol {
    private let saveKey = "savedPlants"

    func fetchAllPlants() async throws -> [Plant] {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            return []
        }

        return try JSONDecoder().decode([Plant].self, from: data)
    }

    func fetchPlant(id: UUID) async throws -> Plant? {
        let plants = try await fetchAllPlants()
        return plants.first { $0.id == id }
    }

    func savePlant(_ plant: Plant) async throws {
        var plants = try await fetchAllPlants()
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
        } else {
            plants.append(plant)
        }

        let data = try JSONEncoder().encode(plants)
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    func deletePlant(_ plant: Plant) async throws {
        var plants = try await fetchAllPlants()
        plants.removeAll { $0.id == plant.id }

        let data = try JSONEncoder().encode(plants)
        UserDefaults.standard.set(data, forKey: saveKey)
    }
}