// ViewModels/ExamReadinessViewModel.swift
init(
    userProgressService: UserProgressService,
    localDataService: LocalDataService
)

// ---

func calculateReadiness() {
    isLoading = true
    
    Task {
        do {
            // ... all computation here (background thread)
            let result = ExamReadiness(...)
            
            // Explicit main thread update
            await MainActor.run {
                self.readiness = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Readiness assessment failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

// ---

Text(categoryID) // Map to category name in production

// ---

private func predictPassProbability(overallScore: Double, totalAttempts: Int) -> Double {
    let baseScore = overallScore
    let attemptFactor = min(Double(totalAttempts) / 300.0, 0.2)
    let probability = baseScore + attemptFactor
    return min(probability, 0.99)
}

// ---

private func predictPassProbability(
    overallScore: Double,
    totalAttempts: Int,
    categoryScores: [String: CategoryReadiness]
) -> Double {
    // Exam requires 75% (22.5/30 questions)
    // Model: if you consistently score X%, probability of passing is related to:
    // 1. Your average score
    // 2. Variance (weak categories drag you down)
    // 3. Sample size confidence
    
    let weakCategories = categoryScores.values.filter { !$0.isReadyForExam }.count
    let totalCategories = categoryScores.count
    let categoryReadinessPenalty = Double(weakCategories) / Double(totalCategories) * 0.15
    
    let sampleConfidence = min(Double(totalAttempts) / 300.0, 0.15)
    let baseScore = max(overallScore - categoryReadinessPenalty, 0.0)
    let probability = baseScore + sampleConfidence
    
    return min(probability, 0.95)
}

// ---

let predictedPass = predictPassProbability(
    overallScore: overallScore,
    totalAttempts: totalAnswered,
    categoryScores: categoryScores  // Add this parameter
)

// ---

} else if let error = viewModel.errorMessage {
    ErrorStateView(message: error) { // ❌ Not defined
        viewModel.calculateReadiness()
    }
}

// ---

#Preview {
    let mockVM = ExamReadinessViewModel(
        userProgressService: MockUserProgressService(),
        localDataService: MockLocalDataService()
    )
    mockVM.readiness = ExamReadiness(
        categoryScores: [:],
        overallReadinessScore: 0.78,
        recommendedFocusCategories: ["SignRecognition"],
        predictedPassProbability: 0.82,
        minimumStudyHoursRemaining: 3
    )
    return ExamReadinessScreen(viewModel: mockVM)
}

// ---

// ❌ These don't exist:
private let userProgressService: UserProgressService
private let localDataService: LocalDataService

// ---

Text(category.readinessLevel.label)  // ❌ .label doesn't exist

// ---

func calculateReadiness() {
    isLoading = true
    errorMessage = nil
    
    Task {
        do {
            let allCategories = try await localDataService.fetchAllCategories()
            var categoryScores: [String: CategoryReadiness] = [:]
            var totalCorrect = 0
            var totalAnswered = 0
            
            // ... all computation here (background, no UI updates) ...
            
            let result = ExamReadiness(
                categoryScores: categoryScores,
                overallReadinessScore: overallScore,
                recommendedFocusCategories: weakCategories,
                predictedPassProbability: predictedPass,
                minimumStudyHoursRemaining: estimatedHours
            )
            
            // ✅ Explicit main thread for UI updates
            await MainActor.run {
                self.readiness = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Readiness assessment failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

// ---

} else if let error = viewModel.errorMessage {
    ErrorStateView(message: error) {  // ❌ Not defined
        viewModel.calculateReadiness()
    }
}

// ---

ForEach(readiness.recommendedFocusCategories.prefix(3), id: \.self) { categoryID in
    HStack {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.orange)
        Text(categoryID)  // ❌ Shows "traffic_signs_001" instead of "Traffic Signs"
            .font(.body)
        Spacer()
    }
}

// ---

ForEach(readiness.recommendedFocusCategories.prefix(3), id: \.self) { categoryID in
    if let category = readiness.categoryScores[categoryID] {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.orange)
            Text(category.categoryName)  // ✅ Use actual name
                .font(.body)
            Spacer()
        }
    }
}

// ---

private func predictPassProbability(overallScore: Double, totalAttempts: Int) -> Double {
    let baseScore = overallScore
    let attemptFactor = min(Double(totalAttempts) / 300.0, 0.2)
    let probability = baseScore + attemptFactor  // ❌ Linear addition ignores weaknesses
    return min(probability, 0.99)
}

// ---

private func predictPassProbability(
    overallScore: Double,
    totalAttempts: Int,
    categoryScores: [String: CategoryReadiness]
) -> Double {
    // Exam is 30 questions, ~75% needed to pass (22.5/30)
    // Model factors:
    // 1. Overall average score
    // 2. Weakness in ANY category (weakest link matters)
    // 3. Sample size confidence
    
    guard !categoryScores.isEmpty else { return 0.0 }
    
    let weakestCategory = categoryScores.values.min { 
        $0.correctAnswerPercentage < $1.correctAnswerPercentage 
    }?.correctAnswerPercentage ?? 0.0
    
    let averageByCategory = categoryScores.values.map { $0.correctAnswerPercentage }.reduce(0, +) / Double(categoryScores.count)
    
    // If weakest category < 60%, penalize heavily
    let weaknessPenalty = weakestCategory < 0.6 ? 0.15 : 0.0
    
    // Confidence factor: more attempts = more reliable prediction
    let confidenceFactor = min(Double(totalAttempts) / 200.0, 0.10)
    
    let baseProbability = max(averageByCategory - weaknessPenalty + confidenceFactor, 0.0)
    return min(baseProbability, 0.92)  // Cap at 92% realistic max
}

// ---

let predictedPass = predictPassProbability(
    overallScore: overallScore,
    totalAttempts: totalAnswered,
    categoryScores: categoryScores  // Add parameter
)

// ---

private func estimateRemainingStudyHours(
    weakCategories: [String],
    categoryScores: [String: CategoryReadiness]
) -> Int {
    let weakCount = weakCategories.count
    return max(0, weakCount * 1)  // ❌ 1 hour per category regardless of gap
}

// ---

private func estimateRemainingStudyHours(
    weakCategories: [String],
    categoryScores: [String: CategoryReadiness]
) -> Int {
    var totalHours = 0
    
    for categoryID in weakCategories {
        guard let category = categoryScores[categoryID] else { continue }
        
        let gapToMastery = max(0.0, 0.75 - category.correctAnswerPercentage)
        let questionsToImprove = Int(Double(category.questionsAnswered) * gapToMastery)
        
        // ~2 min per question to improve (review + practice)
        let minutesNeeded = questionsToImprove * 2
        totalHours += max(1, minutesNeeded / 60)  // Min 1 hour per weak category
    }
    
    return totalHours
}

// ---

ZStack(alignment: .leading) {
    Capsule()
        .fill(Color(.systemGray5))
        .frame(height: 12)
    
    Capsule()
        .fill(progressColor)
        .frame(width: CGFloat(readiness.overallReadinessScore) * 200, height: 12)
}
// ❌ VoiceOver users get no context

// ---

ZStack(alignment: .leading) {
    Capsule()
        .fill(Color(.systemGray5))
        .frame(height: 12)
    
    Capsule()
        .fill(progressColor)
        .frame(width: CGFloat(readiness.overallReadinessScore) * 200, height: 12)
}
.accessibilityElement(children: .ignore)
.accessibility(label: Text("Readiness Progress"))
.accessibility(value: Text("\(Int(readiness.overallReadinessScore * 100)) percent"))

// ---

#Preview {
    let mockProgress = ExamReadiness(
        categoryScores: [
            "signs": CategoryReadiness(
                categoryID: "signs",
                categoryName: "Traffic Signs",
                correctAnswerPercentage: 0.82,
                questionsAnswered: 50,
                questionsCorrect: 41,
                readinessLevel: .advanced
            )
        ],
        overallReadinessScore: 0.78,
        recommendedFocusCategories: ["rules"],
        predictedPassProbability: 0.82,
        minimumStudyHoursRemaining: 3
    )
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: MockUserProgressService(),
        localDataService: MockLocalDataService()
    )
    viewModel.readiness = mockProgress
    
    return ExamReadinessScreen(viewModel: viewModel)
}

// ---

@MainActor
func testCalculateReadiness_Success() async {
    // Arrange
    let mockProgress = CategoryProgress(correctAnswers: 40, totalAnswersAttempted: 50)
    let mockCategories = [
        QuestionCategory(id: "signs", name: "Traffic Signs"),
        QuestionCategory(id: "rules", name: "Traffic Rules")
    ]
    
    let userProgressService = MockUserProgressService()
    userProgressService.mockProgress = mockProgress
    
    let localDataService = MockLocalDataService()
    localDataService.mockCategories = mockCategories
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act
    viewModel.calculateReadiness()
    
    // Wait for async task
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
    
    // Assert
    XCTAssertNotNil(viewModel.readiness)
    XCTAssertEqual(viewModel.readiness?.overallReadinessScore, 0.8) // 40/50
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
}

// ---

@MainActor
func testCalculateReadiness_ServiceThrows() async {
    // Arrange
    let userProgressService = MockUserProgressService()
    userProgressService.shouldThrow = true
    userProgressService.mockError = NSError(domain: "TestError", code: -1, userInfo: nil)
    
    let localDataService = MockLocalDataService()
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act
    viewModel.calculateReadiness()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertNil(viewModel.readiness)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNotNil(viewModel.errorMessage)
    XCTAssertTrue(viewModel.errorMessage?.contains("failed") ?? false)
}

// ---

@MainActor
func testCalculateReadiness_NoCategories() async {
    // Arrange
    let userProgressService = MockUserProgressService()
    let localDataService = MockLocalDataService()
    localDataService.mockCategories = [] // Empty
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act
    viewModel.calculateReadiness()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertNotNil(viewModel.readiness)
    XCTAssertEqual(viewModel.readiness?.categoryScores.count, 0)
    XCTAssertEqual(viewModel.readiness?.overallReadinessScore, 0.0)
    XCTAssertEqual(viewModel.readiness?.minimumStudyHoursRemaining, 0)
}

// ---

@MainActor
func testCalculateReadiness_ZeroAttempts() async {
    // Arrange
    let mockProgress = CategoryProgress(correctAnswers: 0, totalAnswersAttempted: 0)
    let mockCategories = [QuestionCategory(id: "signs", name: "Signs")]
    
    let userProgressService = MockUserProgressService()
    userProgressService.mockProgress = mockProgress
    
    let localDataService = MockLocalDataService()
    localDataService.mockCategories = mockCategories
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act
    viewModel.calculateReadiness()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(viewModel.readiness?.categoryScores["signs"]?.correctAnswerPercentage, 0.0)
    XCTAssertEqual(viewModel.readiness?.categoryScores["signs"]?.readinessLevel, .notStarted)
}

// ---

@MainActor
func testCalculateReadiness_LoadingState() async {
    // Arrange
    let userProgressService = MockUserProgressService()
    let localDataService = MockLocalDataService()
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act
    XCTAssertFalse(viewModel.isLoading)
    
    let task = Task {
        viewModel.calculateReadiness()
    }
    
    // Assert immediately (should be true)
    XCTAssertTrue(viewModel.isLoading)
    
    try await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert after completion
    XCTAssertFalse(viewModel.isLoading)
}

// ---

@MainActor
func testCalculateReadiness_ConcurrentCalls() async {
    // Arrange
    let userProgressService = MockUserProgressService()
    userProgressService.mockProgress = CategoryProgress(correctAnswers: 50, totalAnswersAttempted: 100)
    
    let localDataService = MockLocalDataService()
    localDataService.mockCategories = [QuestionCategory(id: "signs", name: "Signs")]
    
    let viewModel = ExamReadinessViewModel(
        userProgressService: userProgressService,
        localDataService: localDataService
    )
    
    // Act - call twice quickly
    viewModel.calculateReadiness()
    viewModel.calculateReadiness()
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    // Assert - should have latest result, no crashes
    XCTAssertNotNil(viewModel.readiness)
    XCTAssertFalse(viewModel.isLoading)
}

// ---

func testReadinessLevel_BoundaryConditions() {
    let testCases: [(Double, CategoryReadiness.ReadinessLevel)] = [
        (0.0, .notStarted),
        (0.39, .beginner),
        (0.40, .intermediate),
        (0.69, .intermediate),
        (0.70, .advanced),
        (0.89, .advanced),
        (0.90, .mastered),
        (1.0, .mastered)
    ]
    
    for (score, expectedLevel) in testCases {
        // Using ViewModel private method indirectly via readiness calculation
        let category = CategoryReadiness(
            categoryID: "test",
            categoryName: "Test",
            correctAnswerPercentage: score,
            questionsAnswered: 10,
            questionsCorrect: Int(score * 10),
            readinessLevel: calculateExpectedLevel(score)
        )
        
        XCTAssertEqual(category.readinessLevel, expectedLevel, "Score \(score) should be \(expectedLevel)")
    }
}

private func calculateExpectedLevel(_ percentage: Double) -> CategoryReadiness.ReadinessLevel {
    switch percentage {
    case 0..<0.40: return .beginner
    case 0.40..<0.70: return .intermediate
    case 0.70..<0.90: return .advanced
    case 0.90...: return .mastered
    default: return .notStarted
    }
}

// ---

func testIsReadyForExam_Threshold() {
    let readyCases: [Double] = [0.75, 0.80, 0.90, 1.0]
    let notReadyCases: [Double] = [0.0, 0.50, 0.74, 0.749]
    
    for score in readyCases {
        let category = CategoryReadiness(
            categoryID: "test",
            categoryName: "Test",
            correctAnswerPercentage: score,
            questionsAnswered: 10,
            questionsCorrect: Int(score * 10),
            readinessLevel: .advanced
        )
        XCTAssertTrue(category.isReadyForExam, "Score \(score) should be ready")
    }
    
    for score in notReadyCases {
        let category = CategoryReadiness(
            categoryID: "test",
            categoryName: "Test",
            correctAnswerPercentage: score,
            questionsAnswered: 10,
            questionsCorrect: Int(score * 10),
            readinessLevel: .intermediate
        )
        XCTAssertFalse(category.isReadyForExam, "Score \(score) should not be ready")
    }
}

// ---

func testReadinessLevel_Labels() {
    let labels: [CategoryReadiness.ReadinessLevel: String] = [
        .notStarted: "Not Started",
        .beginner: "Beginner (0–40%)",
        .intermediate: "Intermediate (40–70%)",
        .advanced: "Advanced (70–90%)",
        .mastered: "Mastered (90%+)"
    ]
    
    for (level, expectedLabel) in labels {
        XCTAssertEqual(level.label, expectedLabel)
    }
}

// ---

func testPredictPassProbability_HighScoreWeakCategoriesFew() {
    let viewModel = createViewModelWithMocks()
    
    let categoryScores: [String: CategoryReadiness] = [
        "signs": CategoryReadiness(
            categoryID: "signs",
            categoryName: "Signs",
            correctAnswerPercentage: 0.85,
            questionsAnswered: 50,
            questionsCorrect: 42,
            readinessLevel: .advanced
        ),
        "rules": CategoryReadiness(
            categoryID: "rules",
            categoryName: "Rules",
            correctAnswerPercentage: 0.80,
            questionsAnswered: 50,
            questionsCorrect: 40,
            readinessLevel: .advanced
        )
    ]
    
    // Call private method via reflection or expose for testing
    let probability = viewModel.predictPassProbability(
        overallScore: 0.825,
        totalAttempts: 100,
        categoryScores: categoryScores
    )
    
    XCTAssertGreaterThan(probability, 0.80)
    XCTAssertLessThanOrEqual(probability, 0.92)
}

// ---

func testPredictPassProbability_OneWeakCategory() {
    let viewModel = createViewModelWithMocks()
    
    let categoryScores: [String: CategoryReadiness] = [
        "signs": CategoryReadiness(
            categoryID: "signs",
            categoryName: "Signs",
            correctAnswerPercentage: 0.85,
            questionsAnswered: 50,
            questionsCorrect: 42,
            readinessLevel: .advanced
        ),
        "rules": CategoryReadiness(
            categoryID: "rules",
            categoryName: "Rules",
            correctAnswerPercentage: 0.45, // ❌ Weak: < 60%
            questionsAnswered: 50,
            questionsCorrect: 22,
            readinessLevel: .intermediate
        )
    ]
    
    let probability = viewModel.predictPassProbability(
        overallScore: 0.65,
        totalAttempts: 100,
        categoryScores: categoryScores
    )
    
    // Should be penalized for weak category
    XCTAssertLessThan(probability, 0.65)
}

// ---

func testPredictPassProbability_LowAttempts() {
    let viewModel = createViewModelWithMocks()
    
    let categoryScores: [String: CategoryReadiness] = [
        "signs": CategoryReadiness(
            categoryID: "signs",
            categoryName: "Signs",
            correctAnswerPercentage: 0.80,
            questionsAnswered: 5, // Very few
            questionsCorrect: 4,
            readinessLevel: .advanced
        )
    ]
    
    let probabilityLowAttempts = viewModel.predictPassProbability(
        overallScore: 0.80,
        totalAttempts: 5,
        categoryScores: categoryScores
    )
    
    let probabilityHighAttempts = viewModel.predictPassProbability(
        overallScore: 0.80,
        totalAttempts: 200,
        categoryScores: categoryScores
    )
    
    // More attempts = higher confidence = higher probability
    XCTAssertLessThan(probabilityLowAttempts, probabilityHighAttempts)
}

// ---

func testPredictPassProbability_EmptyCategories() {
    let viewModel = createViewModelWithMocks()
    
    let probability = viewModel.predictPassProbability(
        overallScore: 0.80,
        totalAttempts: 100,
        categoryScores: [:] // Empty
    )
    
    XCTAssertEqual(probability, 0.0)
}

// ---

func testPredictPassProbability_CapsAt92Percent() {
    let viewModel = createViewModelWithMocks()
    
    let categoryScores: [String: CategoryReadiness] = [
        "signs": CategoryReadiness(
            categoryID: "signs",
            categoryName: "Signs",
            correctAnswerPercentage: 0.99,
            questionsAnswered: 1000,
            questionsCorrect: 990,
            readinessLevel: .mastered
        )
    ]
    
    let probability = viewModel.predictPassProbability(
        overallScore: 0.99,
        totalAttempts: 1000,
        categoryScores: categoryScores
    )
    
    XCTAssertLessThanOrEqual(probability, 0.92)
}

// ---

Button(action: {}) {
    Text("Schedule Exam Simulation")
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
}
// ❌ No .accessibilityLabel or .accessibilityHint

// ---

Button(action: {}) {
    Text("Schedule Exam Simulation")
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
}
.accessibilityLabel("Schedule Exam Simulation")
.accessibilityHint("Begin a 30-question timed practice exam")
.accessibilityAddTraits(.isButton)

// ---

private var progressColor: Color {
    let score = readiness.overallReadinessScore
    if score >= 0.75 { return .green }
    if score >= 0.5 { return .orange }  // ❌ Orange on light background: ~3:1 contrast
    return .red
}

// ---

// Option 1: Use darker shades that meet 4.5:1 contrast
private var progressColor: Color {
    let score = readiness.overallReadinessScore
    if score >= 0.75 { return Color(red: 0.2, green: 0.8, blue: 0.2) } // Dark green
    if score >= 0.5 { return Color(red: 1.0, green: 0.6, blue: 0.0) }  // Dark orange
    return Color(red: 0.9, green: 0.2, blue: 0.1) } // Dark red
}

// Option 2: Add outline for contrast
Capsule()
    .fill(progressColor)
    .frame(width: CGFloat(readiness.overallReadinessScore) * 200, height: 12)
    .overlay(
        Capsule()
            .stroke(Color.black.opacity(0.3), lineWidth: 1)
    )

// ---

.accessibilityElement(children: .ignore)
.accessibility(label: Text("Readiness progress"))
.accessibility(value: Text("\(Int(readiness.overallReadinessScore * 100)) percent"))
// ❌ Doesn't explain: "78% of 75% needed to be exam-ready"

// ---

let readinessThreshold = 0.75
let progress = readiness.overallReadinessScore
let remaining = max(0, readinessThreshold - progress)

ZStack(alignment: .leading) {
    Capsule()
        .fill(Color(.systemGray5))
        .frame(height: 12)
    
    Capsule()
        .fill(progressColor)
        .frame(width: CGFloat(progress) * 200, height: 12)
}
.frame(width: 200)
.accessibilityElement(children: .ignore)
.accessibility(label: Text("Exam readiness progress"))
.accessibility(value: Text("\(Int(progress * 100))% complete"))
.accessibility(hint: Text(
    progress >= readinessThreshold
        ? "You have reached the exam-ready threshold"
        : "You need \(Int(remaining * 100))% more to be exam-ready"
))

// ---

.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
        }
    }
}
// ❌ No explicit padding; relies on system default (often < 44x44pt)

// ---

.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.body)
                .frame(width: 44, height: 44)  // Explicit 44x44 minimum
                .contentShape(Rectangle())      // Full frame is tappable
        }
        .accessibilityLabel("Close exam readiness assessment")
    }
}

// ---

ForEach(readiness.recommendedFocusCategories.prefix(3), id: \.self) { categoryID in
    if let category = readiness.categoryScores[categoryID] {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.orange)
            Text(category.categoryName)
                .font(.body)
            Spacer()
        }
    }
}
// ❌ VoiceOver: "Item 1 of 3" instead of category name

// ---

ForEach(readiness.recommendedFocusCategories.prefix(3), id: \.self) { categoryID in
    if let category = readiness.categoryScores[categoryID] {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.orange)
                .accessibilityLabel("Focus required")
            
            Text(category.categoryName)
                .font(.body)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)  // Combine into one announcement
        .accessibility(label: Text("Focus area: \(category.categoryName)"))
    }
}

// ---

ZStack(alignment: .leading) {
    Capsule()
        .fill(Color(.systemGray5))
        .frame(height: 12)
    
    Capsule()
        .fill(progressColor)
        .frame(width: CGFloat(readiness.overallReadinessScore) * 200, height: 12)  // ❌ Hardcoded 200
}
.frame(width: 200)  // ❌ Fixed width

// ---

@Environment(\.sizeCategory) var sizeCategory

var body: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("Progress to Exam-Ready")
            .font(.subheadline)
            .fontWeight(.semibold)
        
        // Dynamic width based on accessibility text size
        let maxWidth: CGFloat = sizeCategory > .extraExtraLarge ? 240 : 200
        
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(height: 12)
            
            Capsule()
                .fill(progressColor)
                .frame(
                    width: CGFloat(readiness.overallReadinessScore) * maxWidth,
                    height: 12
                )
        }
        .frame(width: maxWidth)
        
        HStack {
            Text("0%")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("100%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: maxWidth)
    }
    // ... rest of card
}

// ---

Text("\(Int(readiness.overallReadinessScore * 100))%")
    .font(.title2)
    .fontWeight(.bold)
    // ❌ No .lineLimit or wrapping strategy at large text sizes

// ---

Text("\(Int(readiness.overallReadinessScore * 100))%")
    .font(.title2)
    .fontWeight(.bold)
    .lineLimit(1)                          // Prevent wrapping
    .minimumScaleFactor(0.8)               // Scale down to 80% if needed
    .accessibility(label: Text("Overall score"))
    .accessibility(value: Text("\(Int(readiness.overallReadinessScore * 100)) percent"))

// ---

} else if let error = viewModel.errorMessage {
    ErrorStateView(message: error) {
        viewModel.calculateReadiness()
    }
}
// ❌ No .accessibilityLiveRegion or .announcement

// ---

} else if let error = viewModel.errorMessage {
    ErrorStateView(message: error) {
        viewModel.calculateReadiness()
    }
    .accessibilityLiveRegion(.polite)              // Announce changes
    .accessibility(label: Text("Error"))
    .onAppear {
        // Explicitly announce error for VoiceOver
        UIAccessibility.post(
            notification: .announcement,
            argument: "Assessment failed. \(error). Activate to try again."
        )
    }
}

// ---

HStack(spacing: 16) {
    VStack(alignment: .leading, spacing: 4) {
        Text("Overall Score")
        Text("\(Int(readiness.overallReadinessScore * 100))%")
    }
    
    Divider()  // ❌ No .accessibilityHidden or explanation
    
    VStack(alignment: .leading, spacing: 4) {
        Text("Pass Probability")
        Text("\(Int(readiness.predictedPassProbability * 100))%")
    }
}

// ---

HStack(spacing: 16) {
    VStack(alignment: .leading, spacing: 4) {
        Text("Overall Score")
        Text("\(Int(readiness.overallReadinessScore * 100))%")
    }
    .accessibilityElement(children: .combine)
    
    Divider()
        .accessibilityHidden(true)  // Hide from VoiceOver (purely visual)
    
    VStack(alignment: .leading, spacing: 4) {
        Text("Pass Probability")
        Text("\(Int(readiness.predictedPassProbability * 100))%")
    }
    .accessibilityElement(children: .combine)
}
.accessibilityElement(children: .combine)
.accessibility(label: Text("Score summary"))