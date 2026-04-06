extension Subscription {
    /// Returns suggested category IDs for retrieval practice today
    /// Based on questions last attempted 1-3 days ago (optimal window)
    var spaceRepetitionTrigger: [String]? {
        guard state.isPremium else { return nil }
        // Requires integration with QuestionService to query:
        // "Give me categories where user last scored >70% 
        //  between 1 and 3 days ago"
        return nil // Placeholder; requires cross-domain coordination
    }
}