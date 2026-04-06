// Features/EpisodicalMemory/ViewModels/EpisodicalMemoryViewModel.swift

import Foundation
import Combine

@MainActor
final class EpisodicalMemoryViewModel: ObservableObject {
    // MARK: - Published State
    @Published var memories: [Memory] = []
    @Published var filteredMemories: [Memory] = []
    @Published var selectedMemory: Memory?
    @Published var filterState: MemoryFilterState = .init()
    @Published var uiState: UIState = .idle
    @Published var dueForReviewCount: Int = 0
    @Published var suggestedNextAction: NextAction?
    @Published var toastMessage: String?
    
    // MARK: - UI State
    enum UIState: Equatable {
        case idle
        case loading
        case empty
        case success
        case error(String)
        
        static func == (lhs: UIState, rhs: UIState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.empty, .empty), (.success, .success):
                return true
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }
    
    // MARK: - Private State
    private let memoryService: EpisodicalMemoryService
    private let spacedRecallTask: SpacedRecallTask
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        memoryService: EpisodicalMemoryService = .shared,
        spacedRecallTask: SpacedRecallTask = .shared
    ) {
        self.memoryService = memoryService
        self.spacedRecallTask = spacedRecallTask
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Bind service updates to memories
        memoryService.memoriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] memories in
                guard let self = self else { return }
                self.memories = memories
                self.updateStateAfterDataChange()
            }
            .store(in: &cancellables)
        
        // ✅ Publisher-driven filtering with debounce
        Publishers.CombineLatest(
            $filterState.dropFirst(),
            $memories.dropFirst()
        )
        .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _ in
            guard let self = self else { return }
            self.applyCurrentFilter()
        }
        .store(in: &cancellables)
        
        // Bind due-for-review count
        spacedRecallTask.dueTodayPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$dueForReviewCount)
    }
    
    // MARK: - Public Actions
    
    /// Loads all memories from the service.
    /// 
    /// Sets `uiState` to `.loading` initially, then transitions to `.success` or `.empty`
    /// based on data availability. Errors are captured via `uiState.error(_)`.
    func loadMemories() {
        uiState = .loading
        Task {
            do {
                try await memoryService.loadMemories()
                // ✅ Don't set state here — let Combine binding handle it
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Adds a new memory and shows a success toast.
    func addMemory(_ memory: Memory) {
        Task {
            do {
                try await memoryService.addMemory(memory)
                toastMessage = String(localized: "episodicMemory.toast.added")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                toastMessage = nil
            } catch {
                await showError("Fehler beim Hinzufügen: \(error.localizedDescription)")
            }
        }
    }
    
    /// Deletes a memory with error recovery.
    func deleteMemory(_ memory: Memory) {
        Task {
            do {
                try await memoryService.deleteMemory(memory)
                toastMessage = String(localized: "episodicMemory.toast.deleted")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                toastMessage = nil
            } catch {
                await showError("Fehler beim Löschen: \(error.localizedDescription)")
            }
        }
    }
    
    /// Marks a memory as mastered and removes it from the review queue.
    func markAsMastered(_ memory: Memory) {
        Task {
            do {
                var updated = memory
                updated.isMastered = true
                try await memoryService.updateMemory(updated)
                toastMessage = String(localized: "episodicMemory.toast.mastered")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                toastMessage = nil
            } catch {
                await showError("Fehler beim Aktualisieren: \(error.localizedDescription)")
            }
        }
    }
    
    /// Adds or updates a user note on a memory.
    func addNote(_ note: String, to memory: Memory) {
        Task {
            do {
                var updated = memory
                updated.userNote = note
                updated.lastReviewedAt = Date()
                try await memoryService.updateMemory(updated)
                toastMessage = String(localized: "episodicMemory.toast.noteSaved")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                toastMessage = nil
            } catch {
                await showError("Fehler beim Speichern der Notiz: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Filter Methods
    
    /// Toggles difficulty filter. Passing `nil` clears the filter.
    func toggleDifficulty(_ difficulty: MemoryDifficulty) {
        if filterState.difficulties.contains(difficulty) {
            filterState.difficulties.remove(difficulty)
        } else {
            filterState.difficulties.insert(difficulty)
        }
        // ✅ Combine binding handles filtering automatically
    }
    
    /// Clears all difficulty filters.
    func clearDifficultyFilter() {
        filterState.difficulties.removeAll()
    }
    
    /// Toggles category filter.
    func toggleCategory(_ category: String) {
        if filterState.categories.contains(category) {
            filterState.categories.remove(category)
        } else {
            filterState.categories.insert(category)
        }
    }
    
    /// Clears all category filters.
    func clearCategoryFilter() {
        filterState.categories.removeAll()
    }
    
    /// Toggles "due for review" filter.
    func toggleDueForReview() {
        filterState.showDueOnly.toggle()
    }
    
    /// Clears all filters.
    func clearAllFilters() {
        filterState = .init()
    }
    
    /// Selects a memory and computes its next spaced-recall action.
    func selectMemory(_ memory: Memory) {
        selectedMemory = memory
        let action = spacedRecallTask.nextActionForMemory(memory)
        suggestedNextAction = action
    }
    
    // MARK: - Private Helpers
    
    /// Updates UI state after data change (e.g., after load completes).
    private func updateStateAfterDataChange() {
        if case .loading = uiState {
            uiState = memories.isEmpty ? .empty : .success
        }
        applyCurrentFilter()
        updateDueForReviewCount()
    }
    
    /// Applies current filters to the full memories list.
    private func applyCurrentFilter() {
        filteredMemories = memories.filter { memory in
            // Check difficulty filter
            if !filterState.difficulties.isEmpty {
                guard filterState.difficulties.contains(memory.difficulty) else {
                    return false
                }
            }
            
            // Check category filter
            if !filterState.categories.isEmpty {
                guard filterState.categories.contains(memory.questionCategory) else {
                    return false
                }
            }
            
            // Check due for review filter
            if filterState.showDueOnly {
                guard spacedRecallTask.isDueForReview(memory) else {
                    return false
                }
            }
            
            return true
        }
        
        uiState = filteredMemories.isEmpty ? .empty : .success
    }
    
    /// Updates the count of memories due for review today.
    private func updateDueForReviewCount() {
        dueForReviewCount = memories.filter { spacedRecallTask.isDueForReview($0) }.count
    }
    
    /// Shows an error as a toast message (temporary).
    private func showError(_ message: String) {
        uiState = .error(message)
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if case .error = uiState {
                uiState = .success
            }
        }
    }
}

// MARK: - Supporting Types

/// Multi-filter state supporting difficulty, category, and due-for-review filters.

/// Suggested next action for a memory based on spaced recall algorithm.
struct NextAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let actionType: ActionType
    
    enum ActionType {
        case reviewNow
        case reviewTomorrow
        case reviewInThreeDays
        case markMastered
    }
}