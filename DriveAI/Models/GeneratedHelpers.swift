func updateStreak(answeredCorrectly: Bool) -> LearningStreak {
    let today = Calendar.current.startOfDay(for: Date())
    let lastActive = Calendar.current.startOfDay(for: self.lastActiveDate)
    
    guard answeredCorrectly else { return self }
    
    // Same day: no change
    if today == lastActive { return self }
    
    // Next day: increment
    if today == Calendar.current.date(byAdding: .day, value: 1, to: lastActive) {
        return LearningStreak(
            currentDays: currentDays + 1,
            longestDays: max(longestDays, currentDays + 1),
            lastActiveDate: Date()
        )
    }
    
    // Gap (missed days): reset, start new streak
    return LearningStreak(
        currentDays: 1,
        longestDays: longestDays,
        lastActiveDate: Date()
    )
}

// ---

@MainActor
func testRecordAnswerUpdatesProgress() async {
    let mockService = MockLocalDataService()
    let vm = ProgressViewModel(dataService: mockService)
    
    vm.recordAnswer(categoryId: "signs", correct: true)
    
    try await Task.sleep(nanoseconds: 100_000_000)  // Wait for update
    
    XCTAssertEqual(vm.categoryProgress["signs"]?.correctCount, 1)
}

// ---

func reset() -> LearningStreak {
    // Option 1: Reset to yesterday (user missed today, streak broken)
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
    
    return LearningStreak(
        currentDays: 0,
        longestDays: longestDays,
        lastActiveDate: yesterday  // Makes isAtRisk = true tomorrow if no activity
    )
}

// For localization:
var lastActiveText: String {
    let today = Calendar.current.startOfDay(for: .now)
    let lastActive = Calendar.current.startOfDay(for: lastActiveDate)
    let daysDiff = Calendar.current.dateComponents([.day], from: lastActive, to: today).day ?? 0
    
    switch daysDiff {
    case 0:
        return NSLocalizedString("active_today", comment: "User active today")
    case 1:
        return NSLocalizedString("active_yesterday", comment: "User active yesterday")
    case 2...6:
        return String(format: NSLocalizedString("active_days_ago_%d", comment: ""), daysDiff)
    default:
        return NSLocalizedString("not_active", comment: "Not recently active")
    }
}

// ---

var lastActiveText: String {
    NSLocalizedString("active_today", comment: "User was active today")
}

// ---

// In ProgressViewModel
func recordAnswer(categoryId: String, correct: Bool) {
    if correct {
        let isNewDay = !Calendar.current.isDateInToday(userStats.lastStudyDate)
        userStats = userStats.recordStudyDay(if: isNewDay)
    }
}

// ---

let today = Calendar.current.startOfDay(for: .now)
let lastActive = Calendar.current.startOfDay(for: lastActiveDate)

// Case 2: Consecutive day check
let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastActive)!
if today == nextDay { ... }

// ---

func updateAfterCorrectAnswer() -> LearningStreak {
    // Always work in UTC for consistency
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "UTC")!
    
    let today = calendar.startOfDay(for: .now)
    let lastActive = calendar.startOfDay(for: lastActiveDate)
    
    // Same day check
    if today == lastActive {
        return self
    }
    
    // Consecutive day check
    if let nextDay = calendar.date(byAdding: .day, value: 1, to: lastActive),
       today == nextDay {
        let newCurrent = currentDays + 1
        let newLongest = max(newCurrent, longestDays)
        return LearningStreak(
            currentDays: newCurrent,
            longestDays: newLongest,
            lastActiveDate: .now  // Store as-is; comparison uses UTC
        )
    }
    
    // Gap detected
    return LearningStreak(
        currentDays: 1,
        longestDays: longestDays,
        lastActiveDate: .now
    )
}

// ---

func recordAttempt(correct: Bool) -> ProgressSnapshot {
    var updated = self
    updated.attemptCount += 1  // ← Mutates copy
    if correct {
        updated.correctCount += 1
    }
    updated.lastAttemptDate = .now  // ← Uses shared `Date.now`
    return updated
}

// ---

// In ProgressViewModel (future code)
var progress = categoryProgress[categoryId]!

// Thread A: recordAttempt
var updated1 = progress.recordAttempt(correct: true)

// Thread B: also calls recordAttempt on OLD progress
var updated2 = progress.recordAttempt(correct: false)

// Lost update: both return snapshots from original, one overwrites
categoryProgress[categoryId] = updated2  // updated1 is lost

// ---

/// ⚠️ WARNING: Callers must serialize access to the same ProgressSnapshot.
/// Do NOT call recordAttempt() concurrently from multiple threads on the same snapshot.
/// Use @MainActor in ViewModels to enforce serial access.
func recordAttempt(correct: Bool) -> ProgressSnapshot {

// ---

static func calculate(from categoryProgress: [String: ProgressSnapshot]) -> ExamReadiness {
    guard !categoryProgress.isEmpty else {
        return ExamReadiness(score: 0, categoryScores: [:], calculatedAt: .now)
    }
    // ... calculation ...
}

// ---

for (categoryId, progress) in categoryProgress {
    let categoryScore = progress.correctRate  // Returns 0 (guard in computed property)
    scores[categoryId] = 0
    // ...
}

// ---

static func calculate(from categoryProgress: [String: ProgressSnapshot]) -> ExamReadiness {
    guard !categoryProgress.isEmpty else {
        return ExamReadiness(score: 0, categoryScores: [:], calculatedAt: .now)
    }
    
    // Check if ANY category has attempts
    let hasAttempts = categoryProgress.values.contains { $0.attemptCount > 0 }
    guard hasAttempts else {
        // Return neutral state: not started, not failed
        return ExamReadiness(score: -1, categoryScores: [:], calculatedAt: .now)
    }
    
    // ... rest of calculation ...
}

// Update computed property:
var level: String {
    switch score {
    case -1:
        return NSLocalizedString("readiness_not_started", comment: "No attempts yet")
    case 0..<40:
        return NSLocalizedString("readiness_not_ready", comment: "Not ready")
    // ...
    }
}

// ---

func recordStudyDay(if isNewDay: Bool) -> UserStatistics {
    var updated = self
    if isNewDay {
        updated.totalStudyDays += 1
    }
    updated.lastStudyDate = .now
    return updated
}

// ---

let isNewDay = !Calendar.current.isDateInToday(userStats.lastStudyDate)

// ---

/// Returns true if lastStudyDate is before today (in local calendar).
var isLastStudyBeforeToday: Bool {
    let today = Calendar.current.startOfDay(for: .now)
    let lastStudy = Calendar.current.startOfDay(for: lastStudyDate)
    return lastStudy < today
}

/// Marks study session (idempotent for same calendar day).
func recordStudySession() -> UserStatistics {
    let isNewDay = isLastStudyBeforeToday
    var updated = self
    if isNewDay {
        updated.totalStudyDays += 1
    }
    updated.lastStudyDate = .now
    return updated
}

// ---

static let examReadinessWeights: [String: Double] = [
    "verkehrszeichen": 0.25,
    "vorfahrt": 0.25,
    "verkehrsregeln": 0.20,
    "gebuehren": 0.15,
    "fahrtechniken": 0.10,
    "umweltschutz": 0.05
]

// ---

static let examReadinessWeights: [String: Double] = [
    "verkehrszeichen": 0.25,
    "vorfahrt": 0.25,
    "verkehrsregeln": 0.20,
    "gebuehren": 0.15,
    "fahrtechniken": 0.10
    // ❌ Accidentally removed umweltschutz
]

// ---

static let examReadinessWeights: [String: Double] = {
    let weights: [String: Double] = [
        "verkehrszeichen": 0.25,
        // ...
    ]
    let sum = weights.values.reduce(0, +)
    precondition(
        abs(sum - 1.0) < 0.01,
        "Weights must sum to ~1.0, got \(sum)"
    )
    return weights
}()

// ---

var lastActiveText: String {
    // Translates to German, but app may be in English, French, Italian...
    switch daysDiff {
    case 0:
        return NSLocalizedString("streak_active_today", comment: "Active today")
    // ...
    }
}

// ---

var completionPercentage: Double {
    let estimated = (Double(attemptCount) / ProgressConfig.questionsPerCategory) * 100
    return min(estimated, 100)
}

// ---

/// Estimate of category completion (0–100%).
/// NOTE: Based on assumption of ~50 official questions per category.
/// Actual completion should track against the official question database.
var completionPercentage: Double {
    let estimated = (Double(attemptCount) / ProgressConfig.questionsPerCategory) * 100
    return min(estimated, 100)
}

/// Better approach (Phase 1.2, LocalDataService):
/// Store actual total questions per category, not estimated.

// ---

static func newUser() -> UserStatistics {
    UserStatistics(
        userId: UUID(),
        totalStudyDays: 0,  // ← Starts at 0, but should be 1 (first session)
        firstStudyDate: .now,
        lastStudyDate: .now
    )
}

// ---

static func newUser() -> UserStatistics {
    UserStatistics(
        userId: UUID(),
        totalStudyDays: 1,  // ← First session counts as 1 study day
        firstStudyDate: .now,
        lastStudyDate: .now
    )
}

// ---

// This runs 400 times during one 30-question exam
let readiness = ExamReadiness.calculate(from: categoryProgress)

// ---

/// ⚠️ PERFORMANCE: This is O(n) where n = number of categories.
/// Callers should cache the result and only recalculate on progress changes.
static func calculate(from categoryProgress: [String: ProgressSnapshot]) -> ExamReadiness {

// ---

func testRecordCorrectAnswerIncrementsCount() {
    var snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 5,
        correctCount: 4
    )
    
    let updated = snapshot.recordAttempt(correct: true)
    
    XCTAssertEqual(updated.attemptCount, 6)
    XCTAssertEqual(updated.correctCount, 5)
    XCTAssertGreater(updated.lastAttemptDate.timeIntervalSince(snapshot.lastAttemptDate), 0)
}

// ---

func testRecordIncorrectAnswerIncrementsAttemptOnly() {
    var snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 5,
        correctCount: 4
    )
    
    let updated = snapshot.recordAttempt(correct: false)
    
    XCTAssertEqual(updated.attemptCount, 6)
    XCTAssertEqual(updated.correctCount, 4)  // Unchanged
}

// ---

func testCorrectRateCalculation() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 30,
        correctCount: 24
    )
    
    XCTAssertEqual(snapshot.correctRate, 80.0, accuracy: 0.1)
}

// ---

func testCategoryReadyWithSufficientAttemptsAndRate() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 10,
        correctCount: 8  // 80%
    )
    
    XCTAssertTrue(snapshot.isCategoryReady)
}

// ---

func testCompletionPercentageBasedOnAttempts() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 25  // 50% of 50 assumed questions
    )
    
    XCTAssertEqual(snapshot.completionPercentage, 50.0, accuracy: 0.1)
    XCTAssertLessThanOrEqual(snapshot.completionPercentage, 100)
}

// ---

func testCorrectRateWithZeroAttempts() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 0,
        correctCount: 0
    )
    
    XCTAssertEqual(snapshot.correctRate, 0)  // Guard clause handles this
}

// ---

func testFirstAttemptRecording() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs"
    )
    
    let updated = snapshot.recordAttempt(correct: true)
    
    XCTAssertEqual(updated.attemptCount, 1)
    XCTAssertEqual(updated.correctCount, 1)
    XCTAssertEqual(updated.correctRate, 100.0)
}

// ---

func testPerfectScoreAfterManyAttempts() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 50,
        correctCount: 50
    )
    
    XCTAssertEqual(snapshot.correctRate, 100.0)
    XCTAssertTrue(snapshot.isCategoryReady)
}

// ---

func testNotReadyAtBoundary() {
    // 9 attempts = below min 10
    let snapshot1 = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 9,
        correctCount: 8  // 89%, but not enough attempts
    )
    XCTAssertFalse(snapshot1.isCategoryReady)
    
    // 10 attempts but 79% = below min 80%
    let snapshot2 = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 10,
        correctCount: 7  // 70%
    )
    XCTAssertFalse(snapshot2.isCategoryReady)
}

// ---

func testCompletionCappedAt100Percent() {
    let snapshot = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 100  // 200% of assumed 50
    )
    
    XCTAssertEqual(snapshot.completionPercentage, 100)  // Capped
}

// ---

func testNegativeAttemptCountFails() {
    XCTAssertThrowsError(
        try {
            // This should crash with precondition
            _ = ProgressSnapshot(
                categoryId: "signs",
                categoryName: "Traffic Signs",
                attemptCount: -1,
                correctCount: 0
            )
        }() as Void
    ) { error in
        // Precondition fires, crashes in debug
    }
}

// ---

func testCorrectCountExceedsAttempts_Crashes() {
    // In debug, precondition will catch this
    // In release, this would silently corrupt data
    assertPrecondition {
        _ = ProgressSnapshot(
            categoryId: "signs",
            categoryName: "Traffic Signs",
            attemptCount: 5,
            correctCount: 10  // ❌ Invalid
        )
    }
}

// ---

func testSnapshotImmutability() {
    var snapshot1 = ProgressSnapshot(
        categoryId: "signs",
        categoryName: "Traffic Signs",
        attemptCount: 5,
        correctCount: 3
    )
    
    var snapshot2 = snapshot1
    snapshot2 = snapshot2.recordAttempt(correct: true)
    
    // snapshot1 is unchanged
    XCTAssertEqual(snapshot1.attemptCount, 5)
    XCTAssertEqual(snapshot2.attemptCount, 6)
}

// ---

@MainActor
func testStreakIncrementOnConsecutiveDay() {
    let yesterday = Date(timeIntervalSinceNow: -86400)
    
    var streak = LearningStreak(
        currentDays: 5,
        longestDays: 10,
        lastActiveDate: yesterday
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 6)
    XCTAssertEqual(updated.longestDays, 10)  // Not beaten yet
}

// ---

@MainActor
func testNewLongestStreakOnConsecutiveDay() {
    let yesterday = Date(timeIntervalSinceNow: -86400)
    
    var streak = LearningStreak(
        currentDays: 15,
        longestDays: 15,  // Current = longest
        lastActiveDate: yesterday
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 16)
    XCTAssertEqual(updated.longestDays, 16)  // Updated
}

// ---

@MainActor
func testSameDayAnswerNoStreakChange() {
    let now = Date.now
    
    var streak = LearningStreak(
        currentDays: 5,
        longestDays: 10,
        lastActiveDate: now  // Active today
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 5)  // Unchanged
    XCTAssertEqual(updated.longestDays, 10)
}

// ---

@MainActor
func testStreakResetAfterTwoDayGap() {
    let twoDaysAgo = Date(timeIntervalSinceNow: -172800)
    
    var streak = LearningStreak(
        currentDays: 10,
        longestDays: 30,
        lastActiveDate: twoDaysAgo
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 1)  // Reset
    XCTAssertEqual(updated.longestDays, 30)  // Preserved
}

// ---

func testActiveToday() {
    let streak = LearningStreak(
        currentDays: 5,
        longestDays: 10,
        lastActiveDate: .now
    )
    
    XCTAssertTrue(streak.isActiveToday)
}

// ---

func testStreakAtRiskAfterMissingYesterday() {
    let twoDaysAgo = Date(timeIntervalSinceNow: -172800)
    
    let streak = LearningStreak(
        currentDays: 5,
        longestDays: 10,
        lastActiveDate: twoDaysAgo  // No activity yesterday
    )
    
    XCTAssertTrue(streak.isAtRisk)
}

// ---

@MainActor
func testStreakUpdateAcrossMidnight() {
    // Simulate user active at 11:55 PM
    var calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: .now)
    components.hour = 23
    components.minute = 55
    let beforeMidnight = calendar.date(from: components)!
    
    var streak = LearningStreak(
        currentDays: 5,
        longestDays: 10,
        lastActiveDate: beforeMidnight
    )
    
    // Simulate answer at 12:05 AM next day
    // (Mock Date.now in ProgressViewModel test, not here)
    let updated = streak.updateAfterCorrectAnswer()
    
    // Should increment to 6, not reset
    XCTAssertEqual(updated.currentDays, 6)
}

// ---

@MainActor
func testStreakCalculationDuringDSTTransition() {
    // Test for March and October DST transitions
    // This is critical for timezone-safe date math
    
    // Example: Last activity on "spring forward" date
    let dstDate = Calendar.current.date(
        from: DateComponents(year: 2024, month: 3, day: 10, hour: 12)
    )!
    
    var streak = LearningStreak(
        currentDays: 3,
        longestDays: 3,
        lastActiveDate: dstDate
    )
    
    // Next day's activity should increment, despite time zone shift
    let updated = streak.updateAfterCorrectAnswer()
    XCTAssertEqual(updated.currentDays, 4)
}

// ---

func testNewStreakStartsAtOne() {
    let yesterday = Date(timeIntervalSinceNow: -86400 * 5)  // 5 days ago
    
    var streak = LearningStreak(
        currentDays: 0,
        longestDays: 0,
        lastActiveDate: yesterday
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 1)
}

// ---

func testLongStreakPreserved() {
    let yesterday = Date(timeIntervalSinceNow: -86400)
    
    var streak = LearningStreak(
        currentDays: 365,
        longestDays: 365,
        lastActiveDate: yesterday
    )
    
    let updated = streak.updateAfterCorrectAnswer()
    
    XCTAssertEqual(updated.currentDays, 366)
    XCTAssertEqual(updated.longestDays, 366)
}

// ---

func testNegativeCurrentDays_Crashes() {
    assertPrecondition {
        _ = LearningStreak(
            currentDays: -5,  // ❌ Invalid
            longestDays: 10
        )
    }
}

// ---

func testLongestCannotBeLessThanCurrent() {
    // This is allowed by the struct, but semantically wrong
    // Should be caught in ProgressViewModel when updating
    
    let streak = LearningStreak(
        currentDays: 10,
        longestDays: 5  // ❌ Logically invalid, but not caught by precondition
    )
    
    XCTAssertGreaterThanOrEqual(streak.longestDays, streak.currentDays)
}

// ---

func testRecordCorrectAnswerIncrementsStats() {
    var stats = UserStatistics.preview
    let original = stats
    
    stats = stats.recordAttempt(correct: true)
    
    XCTAssertEqual(stats.totalAttempts, original.totalAttempts + 1)
    XCTAssertEqual(stats.totalCorrect, original.totalCorrect + 1)
}

// ---

// In LearningStreak
let today = Calendar.current.startOfDay(for: .now)
let lastActive = Calendar.current.startOfDay(for: lastActiveDate)

// In UserStatistics
let today = Calendar.current.startOfDay(for: .now)
let lastStudy = Calendar.current.startOfDay(for: lastStudyDate)

// In tests
let today = Calendar.current.startOfDay(for: .now)

// ---

func updateAfterCorrectAnswer() -> LearningStreak {
    let today = DateUtilities.today
    let lastActive = DateUtilities.startOfDay(lastActiveDate)
    
    // Same day: no change
    if today == lastActive {
        return self
    }
    
    // Consecutive day: increment
    if let nextDay = DateUtilities.nextDay(after: lastActive), today == nextDay {
        let newCurrent = currentDays + 1
        let newLongest = max(newCurrent, longestDays)
        return LearningStreak(currentDays: newCurrent, longestDays: newLongest, lastActiveDate: .now)
    }
    
    // Gap: reset
    return LearningStreak(currentDays: 1, longestDays: longestDays, lastActiveDate: .now)
}

var isActiveToday: Bool {
    DateUtilities.isToday(lastActiveDate)
}

var isAtRisk: Bool {
    let lastActive = DateUtilities.startOfDay(lastActiveDate)
    let yesterday = DateUtilities.progressCalendar.date(byAdding: .day, value: -1, to: DateUtilities.today) ?? DateUtilities.today
    return lastActive < yesterday
}

// ---

var isLastStudyBeforeToday: Bool {
    DateUtilities.startOfDay(lastStudyDate) < DateUtilities.today
}

var daysSinceStart: Int {
    DateUtilities.daysDifference(from: firstStudyDate, to: .now)
}

func recordStudyDay(if isNewDay: Bool) -> UserStatistics {
    // Caller can now use DateUtilities.daysDifference()
    var updated = self
    if isNewDay {
        updated.totalStudyDays += 1
    }
    updated.lastStudyDate = .now
    return updated
}

// ---

// In LearningStreak
return NSLocalizedString("streak_active_today", comment: "Active today")

// In UserStatistics
return String(format: NSLocalizedString("stats_summary_%d_%d_%s", comment: "Overall stats"), ...)

// In ExamReadiness
return NSLocalizedString("readiness_not_ready", comment: "Not ready for exam")

// ---

var lastActiveText: String {
    let daysDiff = DateUtilities.daysDifference(from: lastActiveDate, to: .now)
    
    switch daysDiff {
    case 0:
        return localize(L10nKeys.Streak.activeToday)
    case 1:
        return localize(L10nKeys.Streak.activeYesterday)
    case 2...6:
        return localize(L10nKeys.Streak.activeDaysAgo, daysDiff)
    default:
        return localize(L10nKeys.Streak.notActive)
    }
}

// ---

var level: String {
    switch score {
    case -1:
        return localize(L10nKeys.Readiness.notStarted)
    case 0..<40:
        return localize(L10nKeys.Readiness.notReady)
    case 40..<60:
        return localize(L10nKeys.Readiness.partiallyReady)
    case 60..<80:
        return localize(L10nKeys.Readiness.almostReady)
    case 80...100:
        return localize(L10nKeys.Readiness.examReady)
    default:
        return localize(L10nKeys.Readiness.unknown)
    }
}

// ---

// In ProgressSnapshot.init
precondition(attemptCount >= 0, "attemptCount must be non-negative")
precondition(correctCount >= 0, "correctCount must be non-negative")
precondition(correctCount <= attemptCount, "correctCount cannot exceed attemptCount")

// In UserStatistics.init
precondition(totalAttempts >= 0, "totalAttempts must be non-negative")
precondition(totalCorrect >= 0, "totalCorrect must be non-negative")
precondition(totalCorrect <= totalAttempts, "totalCorrect cannot exceed totalAttempts")
precondition(categoriesCompleted <= categoriesStarted, "completed cannot exceed started")

// ---

init(
    categoryId: String,
    categoryName: String,
    attemptCount: Int = 0,
    correctCount: Int = 0,
    firstAttemptDate: Date = .now,
    lastAttemptDate: Date = .now
) {
    // Delegated to validator
    try? ProgressValidator.validateAttempts(count: attemptCount, correct: correctCount)
    
    self.id = UUID()
    self.categoryId = categoryId
    self.categoryName = categoryName
    self.attemptCount = attemptCount
    self.correctCount = correctCount
    self.firstAttemptDate = firstAttemptDate
    self.lastAttemptDate = lastAttemptDate
}

// ---

init(
    userId: UUID = UUID(),
    totalAttempts: Int = 0,
    totalCorrect: Int = 0,
    categoriesStarted: Int = 0,
    categoriesCompleted: Int = 0,
    longestStreak: Int = 0,
    totalStudyDays: Int = 1,
    firstStudyDate: Date = .now,
    lastStudyDate: Date = .now
) {
    try? ProgressValidator.validateAttempts(count: totalAttempts, correct: totalCorrect)
    try? ProgressValidator.validateCategories(started: categoriesStarted, completed: categoriesCompleted)
    
    self.userId = userId
    self.totalAttempts = totalAttempts
    // ... rest of init
}