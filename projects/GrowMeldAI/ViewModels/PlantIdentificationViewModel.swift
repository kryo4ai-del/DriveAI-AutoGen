import SwiftUI
import Combine
// ViewModels/PlantIdentificationViewModel.swift
  @MainActor
  class PlantIdentificationViewModel: ObservableObject {
    @Published var plantInfo: PlantInfo?
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    func fetchPlantInfo(plantId: String) async { }
  }