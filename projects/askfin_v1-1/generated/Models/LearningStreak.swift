// ✅ Correct: invariant now enforced at init
let safeCurrent  = max(0, currentDays)
self.longestDays = max(safeCurrent, max(0, longestDays))

// ✅ Correct: custom decoder re-normalises dates after round-trip
self.activeDates = Self.normalised(rawDates)

// ✅ Correct: StreakTier renamed from .none to .inactive
case inactive = "inactive"

// ✅ Correct: Color returned directly, not as String
var color: Color { ... }