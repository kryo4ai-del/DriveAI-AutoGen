struct MemoryFilterState {
    var difficulties: Set<MemoryDifficulty> = []
    var categories: Set<String> = []
    var showDueOnly: Bool = false
    
    var isActive: Bool {
        !difficulties.isEmpty || !categories.isEmpty || showDueOnly
    }
}

func applyCurrentFilter() {
    filteredMemories = memories.filter { memory in
        // Check difficulty
        if !filterState.difficulties.isEmpty,
           !filterState.difficulties.contains(memory.difficulty) {
            return false
        }
        // Check category
        if !filterState.categories.isEmpty,
           !filterState.categories.contains(memory.questionCategory) {
            return false
        }
        // Check due for review
        if filterState.showDueOnly,
           !spacedRecallTask.isDueForReview(memory) {
            return false
        }
        return true
    }
}