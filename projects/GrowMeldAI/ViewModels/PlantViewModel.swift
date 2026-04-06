// PlantViewModel.swift
import Foundation
import Combine
import SwiftUI

@MainActor
final class PlantViewModel: ObservableObject {
    @Published var plant: Plant?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showResult = false

    private let identificationService: PlantIdentificationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(identificationService: PlantIdentificationServiceProtocol = PlantIdentificationService()) {
        self.identificationService = identificationService
    }

    func identifyPlant(from image: UIImage) async {
        isLoading = true
        errorMessage = nil
        plant = nil

        do {
            let identifiedPlant = try await identificationService.identifyPlant(from: image)
            plant = identifiedPlant
            showResult = true
        } catch let error as PlantIdentificationError {
            handleIdentificationError(error)
        } catch {
            errorMessage = "Ein unbekannter Fehler ist aufgetreten."
        }

        isLoading = false
    }

    private func handleIdentificationError(_ error: PlantIdentificationError) {
        switch error {
        case .cameraUnavailable:
            errorMessage = "Kamera nicht verfügbar."
        case .modelLoadFailed:
            errorMessage = "Modell konnte nicht geladen werden."
        case .predictionFailed:
            errorMessage = "Pflanze nicht erkannt."
        case .permissionDenied:
            errorMessage = "Kamerazugriff verweigert."
        }
    }
}