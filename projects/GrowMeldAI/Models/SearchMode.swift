// Sources/Domains/LocationDataProcessing/ViewModels/ExamCenterFinderViewModel.swift
import Foundation
import CoreLocation
import Combine

enum SearchMode {
    case nearby
    case byPostalCode(String)
    case browse
}

@MainActor
class ExamCenterFinderViewModel: ObservableObject {
    @Published var searchMode: SearchMode = .nearby
}