struct CategoryStat: Sendable { }  // ✅ Correct
struct StreakData: Sendable { }    // ✅ Correct
struct RecentMetrics: Sendable { } // ✅ Correct
// But if used across actor boundaries without Sendable, will compile-fail in Swift 6