// ViewModels/DailyReminderViewModel.swift
import Combine

enum ExaminationStatus {
    case preparing
    case inProgress
    case completed
}

@MainActor
final class DailyReminderViewModel: ObservableObject {
    @Published var examinationStatus: ExaminationStatus = .preparing
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setupBindings() {
        Publishers.CombineLatest($examinationStatus, $examinationStatus)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] value1, value2 in
                _ = self
            }
            .store(in: &cancellables)
    }
}