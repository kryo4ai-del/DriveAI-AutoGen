final class RecommendationDeduplicator {
    func deduplicate(_ recommendations: [CoachingRecommendation]) -> [CoachingRecommendation] {
        var seen = Set<(categoryId: String, type: RecommendationType)>()
        return recommendations.filter { rec in
            let key = (categoryId: rec.categoryId, type: rec.type)
            if seen.contains(key) {
                return false  // Skip duplicate
            }
            seen.insert(key)
            return true
        }
    }
}

final class CoachingRecommendationEngine {
    private let deduplicator = RecommendationDeduplicator()
    
    func generate(context: CoachingContext) -> [CoachingRecommendation] {
        let recommendations = strategies
            .compactMap { $0.generateRecommendation(context: context) }
            .sorted { $0.priority > $1.priority }
        
        let deduplicated = deduplicator.deduplicate(recommendations)
        
        return Array(deduplicated.prefix(5))
    }
}