final class TextMatchingService {
    private let searchIndexReady = AtomicBool(false)
    
    /// Optimized fuzzy matching with prefix filtering
    func findMatchingQuestions(
        text: String,
        in database: [Question]
    ) -> [Question] {
        let normalizedSearchText = text.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard !normalizedSearchText.isEmpty else {
            return []
        }
        
        // 1. FILTER: Extract first 3-5 words as prefix (O(n))
        let searchPrefix = normalizedSearchText
            .split(separator: " ")
            .prefix(3)
            .joined(separator: " ")
        
        // 2. FILTER: Find questions containing prefix (much faster, O(n))
        let candidates = database.filter { q in
            q.text.lowercased().contains(searchPrefix)
        }
        
        // 3. RANK: Score only filtered candidates (O(k*m) where k << n)
        let scored = candidates.map { q in
            (question: q, score: levenshteinRatio(q.text.lowercased(), normalizedSearchText))
        }
        
        return scored
            .filter { $0.score >= 0.6 }  // Min threshold
            .sorted { $0.score > $1.score }
            .map { $0.question }
            .prefix(5)  // Return top 5 matches
            .map { $0 }
    }
    
    /// Fast Levenshtein ratio (0.0 to 1.0)
    private func levenshteinRatio(_ s1: String, _ s2: String) -> Double {
        let distance = levenshteinDistance(s1, s2)
        let maxLength = max(s1.count, s2.count)
        return maxLength == 0 ? 1.0 : 1.0 - Double(distance) / Double(maxLength)
    }
    
    /// Standard Levenshtein distance
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        let m = s1.count
        let n = s2.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        for j in 0...n {
            dp[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1[i - 1] == s2[j - 1] ? 0 : 1
                dp[i][j] = min(
                    dp[i - 1][j] + 1,      // deletion
                    dp[i][j - 1] + 1,      // insertion
                    dp[i - 1][j - 1] + cost  // substitution
                )
            }
        }
        
        return dp[m][n]
    }
}

// Helper for thread-safe boolean
private final class AtomicBool {
    private var value: Bool
    private let lock = NSLock()
    
    init(_ initial: Bool = false) {
        self.value = initial
    }
    
    func get() -> Bool {
        lock.withLock { value }
    }
    
    func set(_ newValue: Bool) {
        lock.withLock { value = newValue }
    }
}