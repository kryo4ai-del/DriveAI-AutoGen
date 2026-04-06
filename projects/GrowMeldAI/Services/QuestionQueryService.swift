protocol QuestionQueryService {
    // Core filtering
    func filter(by: QueryFilter) -> [Question]
    
    // Exam-specific (Phase 5 work, but design now)
    func examSimulation(
        count: Int,
        minDifficulty: Int,
        locationBalancing: Bool
    ) -> [Question]
    
    // Metadata access
    func availableLocations() -> [Location]
    func availableSizeClasses() -> [SizeClass]
    func statistics(filter: QueryFilter) -> QueryStatistics
}