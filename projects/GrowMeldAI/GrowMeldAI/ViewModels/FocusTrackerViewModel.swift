// ViewModels/FocusTrackerViewModel.swift
import Foundation
import Combine

final class FocusTrackerViewModel: ObservableObject {
    @Published var masteryRecords: [MasteryRecord] = []
    @Published var overallMastery: Double = 0
    @Published var isLoading: Bool = false
    @Published var allCategoriesReady: Bool = false
    
    private let masteryService: MasteryCalculationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(masteryService: MasteryCalculationServiceProtocol) {
        self.masteryService = masteryService
        setupNotificationObservers()
        loadData()
    }
    
    func refresh() {
        loadData()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default
            .publisher(for: NSNotification.Name("MasteryUpdated"))
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let records = self?.masteryService.fetchMasteryByCategory() ?? []
            let overall = self?.masteryService.fetchOverallMastery() ?? 0
            let allReady = !records.isEmpty && records.allSatisfy { $0.isReadyForExam }
            
            DispatchQueue.main.async { [weak self] in
                self?.masteryRecords = records
                self?.overallMastery = overall
                self?.allCategoriesReady = allReady
                self?.isLoading = false
            }
        }
    }
}