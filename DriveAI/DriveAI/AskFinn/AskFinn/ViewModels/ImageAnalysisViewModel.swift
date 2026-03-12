// ViewModels/ImageAnalysisViewModel.swift
import SwiftUI
import UIKit
import Combine

class ImageAnalysisViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var analyzedSign: TrafficSign?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let imageAnalysisService: ImageAnalysisService
    private var trafficSigns: [TrafficSign] = [] // Loaded from local storage

    init(imageAnalysisService: ImageAnalysisService) {
        self.imageAnalysisService = imageAnalysisService
        loadTrafficSigns() // Load the traffic signs on initialization
    }

    private func loadTrafficSigns() {
        // Logic to load traffic signs from local storage or resources
    }

    func analyzeImage() {
        guard let image = selectedImage else { return }
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.imageAnalysisService.analyzeImage(image)
            DispatchQueue.main.async {
                self.isLoading = false
                if let sign = result {
                    self.analyzedSign = sign
                } else {
                    self.errorMessage = NSLocalizedString("error_no_matching_sign", comment: "")
                }
            }
        }
    }
}