// ViewModels/DailyReminderViewModel.swift
import Foundation
import Combine

@MainActor
final class DailyReminderViewModel: ObservableObject {
    enum ExaminationStatus {
        case preparing
        case inProgress
        case completed
    }

    @Published var examinationStatus: ExaminationStatus = .preparing

    private var cancellables = Set<AnyCancellable>()

    private func setupBindings() {
        Publishers.CombineLatest($examinationStatus, $examinationStatus)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] (value1: ExaminationStatus, value2: ExaminationStatus) in
                _ = self
            }
            .store(in: &cancellables)
    }
}