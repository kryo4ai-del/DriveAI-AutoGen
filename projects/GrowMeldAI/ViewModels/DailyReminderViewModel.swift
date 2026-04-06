// ViewModels/DailyReminderViewModel.swift
@MainActor
final class DailyReminderViewModel: ObservableObject {
    @Published var examinationStatus: ExaminationStatus = .preparing
    
    private func setupBindings() {
        Publishers.CombineLatest(...)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] ... }
            .store(in: &cancellables)
    }
}