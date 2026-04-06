// Sources/Features/Location/ViewModels/ExamProximityViewModel.swift
import Foundation
import Combine

struct ExamCenter: Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String
}

@MainActor

// Define exam center service protocol
protocol ExamCenterServiceProtocol {
    func fetchExamCenters() async throws -> [ExamCenter]
}