// MARK: - ViewModels/TrialViewModel.swift
import Foundation
import Combine

@MainActor
final class TrialViewModel: ObservableObject {
    @Published private(set) var state: TrialState = .notStarted
    @Published private(set) var daysRemaining: Int = 0
    @Published private(set) var currentPeriod: TrialPeriod?

    private let trialService: TrialServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(trialService: TrialServiceProtocol) {
        self.trialService = trialService

        Task {
            await observeTrialState()
        }
    }

    private func observeTrialState() async {
        await trialService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.state = state
                Task {
                    self?.daysRemaining = await self?.trialService.daysRemaining() ?? 0
                    self?.currentPeriod = await self?.trialService.currentPeriod
                }
            }
            .store(in: &cancellables)
    }

    func startTrial() async {
        do {
            try await trialService.startTrial()
        } catch {
            print("Failed to start trial: \(error)")
        }
    }

    func markAsPurchased() async {
        do {
            try await trialService.markAsPurchased()
        } catch {
            print("Failed to mark as purchased: \(error)")
        }
    }

    func refresh() async {
        do {
            try await trialService.refreshState()
        } catch {
            print("Failed to refresh trial state: \(error)")
        }
    }
}