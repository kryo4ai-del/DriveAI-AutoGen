// Pseudocode for readiness calculation:
readinessScore = (
    categoryPerformance: 40%,    // avg correct across all categories
    streakConsistency: 25%,      // current streak / longest streak
    timeInvested: 20%,           // hours studied (log scale, capped)
    recentProgress: 15%          // last 7 days trend
)

weakCategories = categories where (score < 75% AND incorrect_count > 5)
recommendations = generateTailored(weakCategories, timeAvailable, urgency)

// ---

@Published var readinessResult: ExamReadinessResult?
@Published var isLoading: Bool = false
@Published var error: String?
@Published var selectedCategoryID: UUID?  // for drill-down

// Methods:
func calculateReadiness() async
func dismissError()
func startStudyPlan(for category: WeakCategory)

// ---

// In HomeView:
NavigationLink(destination: ExamReadinessView()) {
    Label("Prüfungsbereitschaft prüfen", systemImage: "checkmark.circle.fill")
}

// ---

// Views/ExamReadinessView.swift
.refreshable {
    await viewModel.retryCalculation()
}

// ---

// ReadinessGaugeView.swift
.accessibilityElement(children: .combine)
.accessibilityLabel("Prüfungsbereitschaft")
.accessibilityValue("\(readinessResult.overallScore)% – \(readinessResult.readinessLabel)")
.accessibilityHint("Deine aktuelle Prüfungsbereitschaft basierend auf Lernfortschritt")

// ---

// Services/ReadinessAnalysisService.swift

func calculateReadinessScore(
    categoryPerformance: Double,     // 0–100, avg % correct
    streakMultiplier: Double,        // 0–1, (current / longest)
    timeInvestedScore: Double,       // 0–100, log-scaled hours
    recentTrendScore: Double         // 0–100, last 7 days momentum
) -> Int {
    let weighted =
        (categoryPerformance * 0.40) +
        (streakMultiplier * 100 * 0.25) +
        (timeInvestedScore * 0.20) +
        (recentTrendScore * 0.15)
    
    return Int(min(max(weighted, 0), 100))
}

// Example:
// Cat: 78%, Streak: 0.8, Time: 65/100, Trend: 72% → 74% readiness

// ---

func test_scoreWeighting_allComponentsBalanced() {
    let service = ReadinessAnalysisService(dataService: mockDataService)
    
    // Test: 100% cat, 0% streak, 0% time, 0% trend
    let score1 = service.calculateReadinessScore(
        categoryPerformance: 100, streakMultiplier: 0, 
        timeInvestedScore: 0, recentTrendScore: 0
    )
    XCTAssertEqual(score1, 40)  // 100 * 0.40
    
    // Test: All balanced at 80%
    let score2 = service.calculateReadinessScore(
        categoryPerformance: 80, streakMultiplier: 0.8,
        timeInvestedScore: 80, recentTrendScore: 80
    )
    XCTAssertEqual(score2, 80)  // Weighted avg
}

// ---

// App.swift (if using NavigationStack)
@StateObject var navigationModel: NavigationModel

NavigationStack(path: $navigationModel.path) {
    HomeView()
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .examReadiness:
                ExamReadinessView()
                    .environmentObject(ExamReadinessViewModel(
                        analysisService: container.analysisService,
                        dataService: container.dataService
                    ))
            // ... other cases
            }
        }
}

// ---

// In WeakCategoriesCard
NavigationLink(value: NavigationDestination.categoryQuestions(category.id)) {
    HStack {
        Text(category.name)
        Spacer()
        Text("\(category.correctPercentage)%")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// ---

// LocalDataService extensions (add if missing)
func getCategoryStatistics() async throws -> [CategoryStats] {
    // SELECT category_id, 
    //        COUNT(*) as attempts,
    //        SUM(is_correct) as correct_count
    // GROUP BY category_id
}

func getTimeSpentByCategory() async throws -> [UUID: TimeInterval] {
    // Extract from question attempt timestamps
}

// ---

// Localizable.strings (de)
"readiness.gauge.label" = "Prüfungsbereitschaft";
"readiness.level.insufficient" = "Unzureichend";
"readiness.level.poor" = "Schwach";
// ... etc

// ---

Text(LocalizedStringKey("readiness.gauge.label"))

// ---

// BROKEN: Lock acquired, released, then cache accessed again
if !forceRefresh {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    
    if let (result, timestamp) = cachedResult,  // ← Released before access completes
       Date().timeIntervalSince(timestamp) < cacheTTL {
        return result  // ← Race window here
    }
}

// ... later, in _computeReadiness:
cacheLock.lock()
self.cachedResult = (result, .now)  // ← Could write while being read above
cacheLock.unlock()

// ---

func calculateReadiness(forceRefresh: Bool = false) async throws -> ExamReadinessResult {
    return try await cacheLock.withLock {
        if !forceRefresh, 
           let (result, timestamp) = cachedResult,
           Date().timeIntervalSince(timestamp) < cacheTTL {
            return result
        }
        
        let result = try await _computeReadiness()
        cachedResult = (result, .now)
        return result
    }
}

// ---

private let cacheLock = os_unfair_lock()
private var cachedResult: (ExamReadinessResult, Date)?

func calculateReadiness(forceRefresh: Bool = false) async throws -> ExamReadinessResult {
    let cached: ExamReadinessResult? = withLock {
        guard !forceRefresh,
              let (result, timestamp) = cachedResult,
              Date().timeIntervalSince(timestamp) < cacheTTL
        else { return nil }
        return result
    }
    
    if let cached = cached { return cached }
    
    let result = try await _computeReadiness()
    
    withLock {
        self.cachedResult = (result, .now)
    }
    
    return result
}

private func withLock<T>(_ body: () -> T) -> T {
    os_unfair_lock_lock(&cacheLock)
    defer { os_unfair_lock_unlock(&cacheLock) }
    return body()
}

// ---

let stats = try await dataService.getCategoryStatistics()        // ❌ Not defined
let timeSpent = try await dataService.getTotalTimeSpentMinutes() // ❌ Not defined
let streakData = try await dataService.getLearningStreakData()   // ❌ Not defined
let recentMetrics = try await dataService.getRecentPerformanceMetrics() // ❌ Not defined

// ---

init(analysisService: ..., dataService: ...) {
    // ❌ Called from non-MainActor context (e.g., container setup)
    // ❌ Swift 6 strict concurrency will error
}

// ---

nonisolated init(
    analysisService: ReadinessAnalysisService,
    dataService: LocalDataService
) {
    self.analysisService = analysisService
    self.dataService = dataService
}

// OR use factory on MainActor:
@MainActor
static func create(
    analysisService: ReadinessAnalysisService,
    dataService: LocalDataService
) -> ExamReadinessViewModel {
    ExamReadinessViewModel(
        analysisService: analysisService,
        dataService: dataService
    )
}

// ---

/// Retry calculation with fresh data
func retryCalculation() async {
    await calculateReadiness(forceRefresh: true)
}

/// Dismiss error banner
func dismissError() {
    error = nil
}

// ---

import Foundation

// ❌ Color not imported
var readinessColor: Color { ... }

// ---

import Foundation
import SwiftUI  // ← Add this

// ✅ Now Color is available
var readinessColor: Color { ... }

// ---

let avgPercentage = completedCategories.map { category -> Double in
    Double(category.correctCount) / Double(category.totalAttempts)
    // ❌ Crashes if totalAttempts == 0 (even after guard, logic is wrong)
}.reduce(0, +) / Double(completedCategories.count)

// ---

let avgPercentage = completedCategories
    .compactMap { category -> Double? in
        guard category.totalAttempts > 0 else { return nil }
        return Double(category.correctCount) / Double(category.totalAttempts)
    }
    .reduce(0, +) / Double(completedCategories.count)

// ---

private func estimateTimeForCategory(_ category: WeakCategory) -> Int {
    // ~2 minutes per question + 5 min overhead
    return min((category.questionsRemaining * 2) + 5, 45)
    // ❌ If 30 questions remain, estimate = min(65, 45) = 45 min (WAY too low)
    // ❌ Users will see "~45 min" but actual need is 65 min
}

// ---

private func estimateTimeForCategory(_ category: WeakCategory) -> Int {
    // 2 min per question + 5 min overhead, no artificial cap
    return (category.questionsRemaining * 2) + 5
}

// If you need a cap, apply it elsewhere (max 90 min per recommendation)

// ---

let gap = passThreshold - metric.correctPercentage
// ✅ Correct

let remaining = max(0, Int(Double(metric.totalAttempts) * 0.25))
// ❌ Wrong: Assumes 25% of already-attempted questions remain
// Should estimate: "how many NEW questions to reach 75%?"

// ---

let remaining = estimateQuestionsToPass(
    currentCorrect: metric.correctCount,
    currentTotal: metric.totalAttempts,
    targetPercentage: passThreshold
)

private func estimateQuestionsToPass(
    currentCorrect: Int,
    currentTotal: Int,
    targetPercentage: Int
) -> Int {
    let targetPercent = Double(targetPercentage) / 100.0
    let targetCorrect = Double(currentTotal) * targetPercent
    
    if Double(currentCorrect) >= targetCorrect {
        return 0  // Already passed
    }
    
    // Assume 70% success rate on new questions
    let neededCorrect = Int(ceil(targetCorrect)) - currentCorrect
    let estimatedQuestions = Int(ceil(Double(neededCorrect) / 0.7))
    
    return min(estimatedQuestions, 50)  // Cap at 50
}

// ---

func invalidateCache() {
    cacheLock.lock()
    self.cachedResult = nil
    cacheLock.unlock()
}

// ---

// In ViewModel
func recordQuizCompletion() async {
    // ... process results
    analysisService.invalidateCache()
    await calculateReadiness(forceRefresh: true)
}

// ---

return "Die Prüfungsbereitschaft konnte nicht berechnet werden..."  // ❌
return "Fokussiere auf \(category.categoryName) – \(category.questionsRemaining)..."  // ❌

// ---

let errorMsg = String(localized: "readiness.error.calculation.failed")
// Localizable.strings: "readiness.error.calculation.failed" = "Die Prüfungsbereitschaft konnte nicht...";

// ---

@Published var readinessResult: ExamReadinessResult?
// ❌ @Published is not Sendable-safe by default

private var cancellables = Set<AnyCancellable>()
// ❌ AnyCancellable is not Sendable; Set<AnyCancellable> violates Sendable

// ---

@Published private(set) var readinessResult: ExamReadinessResult?
// Remove cancellables if not using combine; if needed:
nonisolated private var cancellables = Set<AnyCancellable>()
// But this is risky—better to avoid Combine in @MainActor

// ---

// In CategoryMetric
var scoreColor: Color {
    switch correctPercentage {
    case 80...: return .green
    case 60..<80: return .yellow
    default: return .red
    }
}

// In ReadinessLevel (different thresholds)
var color: Color {
    switch self {
    case .insufficient: return Color(red: 0.9, green: 0.2, blue: 0.2)
    ...
    }
}

// In views: repeated color logic

// ---

// In models
return "Fokussiere auf \(category.categoryName) – \(category.questionsRemaining) Fragen offen"

// In service
return "Die Prüfungsbereitschaft konnte nicht berechnet werden..."

// In ViewModel
error = "..."

// ---

// In ReadinessMetrics
var timeInvestedFormatted: String {
    let hours = timeInvestedMinutes / 60
    let mins = timeInvestedMinutes % 60
    if hours > 0 { return "\(hours)h \(mins)min" }
    return "\(mins)min"
}

// In ReadinessRecommendation
var timeEstimate: String {
    if estimatedMinutes < 60 {
        return "~\(estimatedMinutes) min"
    }
    let hours = estimatedMinutes / 60
    let mins = estimatedMinutes % 60
    return "~\(hours)h \(mins)min"
}

// In Service
let timeNeeded = estimateTimeForCategory(weakCategory)

// ---

// In service
let passThreshold = 75

// In ViewModel
if score > 75 { ... }

// In views
if percentage >= 90 { ... }

// ---

@Published var readinessResult: ExamReadinessResult?
@Published var isLoading: Bool = false
@Published var error: String?

// Exposed:
func calculateReadiness(forceRefresh: Bool = false) async { ... }
func retryCalculation() async { ... }
func dismissError() { ... }

// ---

func test_calculateCategoryPerformance_allCategoriesPassed() {
    // Given: 3 categories, all at 85%+
    let stats = [
        CategoryStat(categoryID: UUID(), categoryName: "Cat1", correctCount: 34, totalAttempts: 40),
        CategoryStat(categoryID: UUID(), categoryName: "Cat2", correctCount: 43, totalAttempts: 50),
        CategoryStat(categoryID: UUID(), categoryName: "Cat3", correctCount: 38, totalAttempts: 45)
    ]
    
    // When
    let performance = service.calculateCategoryPerformance(from: stats)
    
    // Then
    XCTAssertEqual(performance, 86, accuracy: 1)  // (85 + 86 + 84) / 3 ≈ 85
}

func test_calculateCategoryPerformance_noAttempts() {
    // Given: categories with zero attempts
    let stats = [
        CategoryStat(categoryID: UUID(), categoryName: "Cat1", correctCount: 0, totalAttempts: 0),
        CategoryStat(categoryID: UUID(), categoryName: "Cat2", correctCount: 0, totalAttempts: 0)
    ]
    
    // When
    let performance = service.calculateCategoryPerformance(from: stats)
    
    // Then
    XCTAssertEqual(performance, 0)
}

func test_calculateCategoryPerformance_mixedProgress() {
    // Given: some categories started, others not
    let stats = [
        CategoryStat(categoryID: UUID(), categoryName: "Started", correctCount: 10, totalAttempts: 20),
        CategoryStat(categoryID: UUID(), categoryName: "NotStarted", correctCount: 0, totalAttempts: 0)
    ]
    
    // When
    let performance = service.calculateCategoryPerformance(from: stats)
    
    // Then: Should only average the started category
    XCTAssertEqual(performance, 50, accuracy: 1)
}

func test_calculateCategoryPerformance_singleQuestion() {
    // Edge case: user answered only 1 question
    let stats = [
        CategoryStat(categoryID: UUID(), categoryName: "OnlyOne", correctCount: 1, totalAttempts: 1)
    ]
    
    // When
    let performance = service.calculateCategoryPerformance(from: stats)
    
    // Then
    XCTAssertEqual(performance, 100)
}

func test_calculateCategoryPerformance_allWrong() {
    // Edge case: 0% in all categories
    let stats = [
        CategoryStat(categoryID: UUID(), categoryName: "AllWrong", correctCount: 0, totalAttempts: 50)
    ]
    
    // When
    let performance = service.calculateCategoryPerformance(from: stats)
    
    // Then
    XCTAssertEqual(performance, 0)
}

// ---

func test_calculateStreakScore_perfectStreak() {
    // Given: current streak = longest streak
    let data = StreakData(currentDays: 30, longestDays: 30)
    
    // When
    let score = service.calculateStreakScore(from: data)
    
    // Then
    XCTAssertEqual(score, 100)
}

func test_calculateStreakScore_noStreak() {
    // Given: no streak data
    let data = StreakData(currentDays: 0, longestDays: 30)
    
    // When
    let score = service.calculateStreakScore(from: data)
    
    // Then
    XCTAssertEqual(score, 0)
}

func test_calculateStreakScore_halfOfLongest() {
    // Given: current = 50% of longest
    let data = StreakData(currentDays: 15, longestDays: 30)
    
    // When
    let score = service.calculateStreakScore(from: data)
    
    // Then: Should scale to 0-100
    XCTAssertEqual(score, 50, accuracy: 1)
}

func test_calculateStreakScore_longestIsZero() {
    // Edge case: no history
    let data = StreakData(currentDays: 5, longestDays: 0)
    
    // When
    let score = service.calculateStreakScore(from: data)
    
    // Then: Avoid division by zero
    XCTAssertEqual(score, 0)
}

func test_calculateStreakScore_currentExceedsLongest() {
    // Edge case: current > longest (shouldn't happen, but handle)
    let data = StreakData(currentDays: 40, longestDays: 30)
    
    // When
    let score = service.calculateStreakScore(from: data)
    
    // Then: Should cap at 100
    XCTAssertEqual(score, 100)
}

// ---

func test_calculateTimeInvestedScore_ninetyMinutes() {
    // Given: 90 minutes (1.5 hours)
    // Expected: log(91) / log(600) * 100 ≈ 39
    
    // When
    let score = service.calculateTimeInvestedScore(minutes: 90)
    
    // Then
    XCTAssertEqual(score, 39, accuracy: 2)
}

func test_calculateTimeInvestedScore_sixHours() {
    // Given: 360 minutes (6 hours)
    let score = service.calculateTimeInvestedScore(minutes: 360)
    
    // Then: Should approach but not exceed 100
    XCTAssert(score > 70 && score < 100)
}

func test_calculateTimeInvestedScore_tenHours() {
    // Given: 600 minutes (10 hours, our log base)
    let score = service.calculateTimeInvestedScore(minutes: 600)
    
    // Then: Should be close to 100
    XCTAssertEqual(score, 100, accuracy: 1)
}

func test_calculateTimeInvestedScore_zeroMinutes() {
    // Given: no time invested
    let score = service.calculateTimeInvestedScore(minutes: 0)
    
    // Then
    XCTAssertEqual(score, 0)
}

func test_calculateTimeInvestedScore_oneMinute() {
    // Edge case: minimal time
    let score = service.calculateTimeInvestedScore(minutes: 1)
    
    // Then: Should be small but > 0
    XCTAssert(score > 0 && score < 10)
}

func test_calculateTimeInvestedScore_hundredHours() {
    // Edge case: extreme time (capped at 100)
    let score = service.calculateTimeInvestedScore(minutes: 6000)
    
    // Then
    XCTAssertEqual(score, 100)
}

// ---

func test_calculateRecentTrendScore_highAccuracyHighConsistency() {
    // Given: 90% accuracy over 7 days, 7 sessions
    let recent = RecentMetrics(
        last7DaysAttempts: 100,
        last7DaysCorrect: 90,
        last7DaysSessions: 7,
        lastSessionDate: Date()
    )
    
    // When
    let score = service.calculateRecentTrendScore(from: recent)
    
    // Then: (90 * 0.8) + (7/7 * 20) = 72 + 20 = 92
    XCTAssertEqual(score, 92, accuracy: 1)
}

func test_calculateRecentTrendScore_lowAccuracyLowConsistency() {
    // Given: 40% accuracy, 2 sessions in 7 days
    let recent = RecentMetrics(
        last7DaysAttempts: 50,
        last7DaysCorrect: 20,
        last7DaysSessions: 2,
        lastSessionDate: Date()
    )
    
    // When
    let score = service.calculateRecentTrendScore(from: recent)
    
    // Then: (40 * 0.8) + (2/7 * 20) ≈ 32 + 5.7 = 37.7
    XCTAssertEqual(score, 38, accuracy: 2)
}

func test_calculateRecentTrendScore_noRecentAttempts() {
    // Given: no attempts in last 7 days
    let recent = RecentMetrics(
        last7DaysAttempts: 0,
        last7DaysCorrect: 0,
        last7DaysSessions: 0,
        lastSessionDate: Date()
    )
    
    // When
    let score = service.calculateRecentTrendScore(from: recent)
    
    // Then
    XCTAssertEqual(score, 0)
}

func test_calculateRecentTrendScore_perfectWeek() {
    // Edge case: 100% accuracy, daily sessions
    let recent = RecentMetrics(
        last7DaysAttempts: 50,
        last7DaysCorrect: 50,
        last7DaysSessions: 7,
        lastSessionDate: Date()
    )
    
    // When
    let score = service.calculateRecentTrendScore(from: recent)
    
    // Then: (100 * 0.8) + (7/7 * 20) = 100
    XCTAssertEqual(score, 100)
}

func test_calculateRecentTrendScore_consistencyBonusCapped() {
    // Given: consistency bonus should cap at 20
    let recent = RecentMetrics(
        last7DaysAttempts: 20,
        last7DaysCorrect: 20,
        last7DaysSessions: 100,  // Way more than 7
        lastSessionDate: Date()
    )
    
    // When
    let score = service.calculateRecentTrendScore(from: recent)
    
    // Then: Should still cap bonus at 20
    XCTAssertEqual(score, 100)
}

// ---

func test_calculateOverallScore_allComponentsBalanced() {
    // Given: all components at 80%
    // Weights: 40% + 25% + 20% + 15% = 100%
    let score = service.calculateOverallScore(
        categoryPerformance: 80,
        streakScore: 80,
        timeInvestedScore: 80,
        recentTrendScore: 80
    )
    
    // When/Then: Should be 80
    XCTAssertEqual(score, 80)
}

func test_calculateOverallScore_unevenComponents() {
    // Given: cat=100, streak=0, time=50, trend=50
    // (100*0.4) + (0*0.25) + (50*0.2) + (50*0.15) = 40 + 0 + 10 + 7.5 = 57.5
    let score = service.calculateOverallScore(
        categoryPerformance: 100,
        streakScore: 0,
        timeInvestedScore: 50,
        recentTrendScore: 50
    )
    
    // When/Then
    XCTAssertEqual(score, 57)
}

func test_calculateOverallScore_boundaryZero() {
    // Given: all components zero
    let score = service.calculateOverallScore(
        categoryPerformance: 0,
        streakScore: 0,
        timeInvestedScore: 0,
        recentTrendScore: 0
    )
    
    // When/Then
    XCTAssertEqual(score, 0)
}

func test_calculateOverallScore_boundaryHundred() {
    // Given: all components at max
    let score = service.calculateOverallScore(
        categoryPerformance: 100,
        streakScore: 100,
        timeInvestedScore: 100,
        recentTrendScore: 100
    )
    
    // When/Then
    XCTAssertEqual(score, 100)
}

func test_calculateOverallScore_exceedsHundred() {
    // Edge case: rounding errors result in >100
    let score = service.calculateOverallScore(
        categoryPerformance: 100,
        streakScore: 100,
        timeInvestedScore: 100,
        recentTrendScore: 100
    )
    
    // Then: Should be capped at 100, not exceed
    XCTAssert(score <= 100)
}

func test_calculateOverallScore_negativesHandled() {
    // Edge case: negative input (shouldn't happen, but defensive)
    let score = service.calculateOverallScore(
        categoryPerformance: -10,
        streakScore: -5,
        timeInvestedScore: 50,
        recentTrendScore: 50
    )
    
    // Then: Should be clamped to ≥ 0
    XCTAssert(score >= 0)
}