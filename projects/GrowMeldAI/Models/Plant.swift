// Models/Domain/Plant.swift
import Foundation

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    let scientificName: String
    let commonName: String
    let family: String
    let description: String
    let isEdible: Bool
    let isToxic: Bool
    let imageName: String?
    let characteristics: [PlantCharacteristic]

    struct PlantCharacteristic: Codable, Equatable {
        let type: CharacteristicType
        let value: String

        enum CharacteristicType: String, Codable, CaseIterable {
            case leafShape = "leaf_shape"
            case flowerColor = "flower_color"
            case growthHeight = "growth_height"
            case season
        }
    }
}

// Models/Domain/PlantIdentification.swift
import Foundation

struct PlantIdentification: Identifiable, Equatable {
    let id: UUID
    let plant: Plant
    let confidence: Double
    let timestamp: Date
    let imageData: Data?
    let userConfidence: Double?
    let isCorrect: Bool?
}

// Models/Domain/PlantCategory.swift
import Foundation

enum PlantCategory: String, CaseIterable, Codable {
    case trees = "Laubbäume"
    case flowers = "Blumenwiesen"
    case shrubs = "Sträucher"
    case grasses = "Gräser"
    case ferns = "Farne"
    case mosses = "Moose"

    var displayName: String {
        rawValue
    }
}

// Services/PlantIdentificationService.swift
import Foundation
import Combine

protocol PlantIdentificationServiceProtocol {
    func identifyPlant(from imageData: Data) async throws -> PlantIdentification
    func loadPlantHistory() async throws -> [PlantIdentification]
    func saveIdentification(_ identification: PlantIdentification) async throws
}

final class PlantIdentificationService: PlantIdentificationServiceProtocol {
    private let localDataService: LocalDataServiceProtocol
    private let apiService: PlantAPIServiceProtocol
    private let userDefaults: UserDefaultsServiceProtocol

    init(
        localDataService: LocalDataServiceProtocol,
        apiService: PlantAPIServiceProtocol,
        userDefaults: UserDefaultsServiceProtocol
    ) {
        self.localDataService = localDataService
        self.apiService = apiService
        self.userDefaults = userDefaults
    }

    func identifyPlant(from imageData: Data) async throws -> PlantIdentification {
        // Validate image data
        guard !imageData.isEmpty else {
            throw PlantError.invalidImageData
        }

        // Try local identification first
        if let localResult = try? await localDataService.identifyPlantLocally(imageData) {
            return localResult
        }

        // Fall back to API
        let apiResult = try await apiService.identifyPlant(imageData)
        let identification = PlantIdentification(
            id: UUID(),
            plant: apiResult.plant,
            confidence: apiResult.confidence,
            timestamp: Date(),
            imageData: imageData,
            userConfidence: nil,
            isCorrect: nil
        )

        try await localDataService.saveIdentification(identification)
        return identification
    }

    func loadPlantHistory() async throws -> [PlantIdentification] {
        try await localDataService.loadPlantHistory()
    }

    func saveIdentification(_ identification: PlantIdentification) async throws {
        try await localDataService.saveIdentification(identification)
    }
}

enum PlantError: Error, LocalizedError {
    case invalidImageData
    case identificationFailed
    case databaseError(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Das Bild konnte nicht verarbeitet werden. Bitte versuche es erneut."
        case .identificationFailed:
            return "Die Pflanzenerkennung ist fehlgeschlagen. Bitte versuche es später noch einmal."
        case .databaseError(let message):
            return "Datenbankfehler: \(message)"
        case .apiError(let message):
            return "API-Fehler: \(message)"
        }
    }
}