import Foundation
import SwiftUI
import Combine

@MainActor
class EpisodicalMemoriesViewModel: ObservableObject {
    @Published var memories: [EpisodicalMemory] = []
    @Published var filteredMemories: [EpisodicalMemory] = []
    @Published var sortOption: SortOption = .newestFirst
    @Published var filterTag: EpisodicalMemory.EmotionalTag?
    @Published var selectedMemory: EpisodicalMemory?
    @Published var isDetailPresented = false
    
    @ObservedObject var memoryService: EpisodicalMemoryService
    
    enum SortOption: String, CaseIterable {
        case newestFirst = "Neueste zuerst"
        case oldestFirst = "Älteste zuerst"
        case mostConfident = "Höchstes Vertrauen"
        case leastConfident = "Niedrigstes Vertrauen"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var updateTask: Task<Void, Never>?
    
    init(memoryService: EpisodicalMemoryService) {
        self.memoryService = memoryService
        observeMemoriesWithCombine()
        observeSortAndFilter()
    }
    
    /// ✅ Use Combine instead of infinite polling
    private func observeMemoriesWithCombine() {
        memoryService.$memories
            .dropFirst() // Ignore initial empty state
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateFilteredMemories()
                }
            }
            .store(in: &cancellables)
    }
    
    /// ✅ Debounce sort/filter changes
    private func observeSortAndFilter() {
        Publishers.CombineLatest($sortOption, $filterTag)
            .dropFirst()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateFilteredMemories()
                }
            }
            .store(in: &cancellables)
    }
    
    func updateFilteredMemories() {
        var filtered = memoryService.memories
        
        // Apply tag filter
        if let tag = filterTag {
            filtered = filtered.filter { $0.emotionalTag == tag }
        }
        
        // Apply sorting
        filtered = sortMemories(filtered)
        
        self.filteredMemories = filtered
    }
    
    private func sortMemories(_ list: [EpisodicalMemory]) -> [EpisodicalMemory] {
        switch sortOption {
        case .newestFirst:
            return list.sorted { $0.timestamp > $1.timestamp }
        case .oldestFirst:
            return list.sorted { $0.timestamp < $1.timestamp }
        case .mostConfident:
            return list.sorted { $0.confidence > $1.confidence }
        case .leastConfident:
            return list.sorted { $0.confidence < $1.confidence }
        }
    }
    
    func selectMemory(_ memory: EpisodicalMemory) {
        selectedMemory = memory
        isDetailPresented = true
    }
    
    func setSortOption(_ option: SortOption) {
        sortOption = option
    }
    
    func setFilterTag(_ tag: EpisodicalMemory.EmotionalTag?) {
        filterTag = tag
    }
    
    /// ✅ ID-preserving update
    func updateMemoryContext(_ id: UUID, context: String, confidence: Int) async {
        do {
            if let index = memoryService.memories.firstIndex(where: { $0.id == id }) {
                let original = memoryService.memories[index]
                let updated = EpisodicalMemory(
                    id: original.id, // ✅ PRESERVE ID
                    questionCategoryId: original.questionCategoryId,
                    questionId: original.questionId,
                    userAnswer: original.userAnswer,
                    correctAnswer: original.correctAnswer,
                    isCorrect: original.isCorrect,
                    emotionalTag: original.emotionalTag,
                    context: context,
                    confidence: confidence
                )
                try await memoryService.updateMemory(updated)
            }
        } catch {
            // Error is handled by service
        }
    }
    
    func deleteMemory(_ id: UUID) async {
        do {
            try await memoryService.deleteMemory(id)
        } catch {
            // Error is handled by service
        }
    }
    
    deinit {
        cancellables.removeAll()
        updateTask?.cancel()
    }
}