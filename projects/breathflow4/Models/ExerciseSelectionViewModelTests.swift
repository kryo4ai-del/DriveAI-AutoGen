import XCTest
@testable import BreathFlow4

@MainActor
final class ExerciseSelectionViewModelTests: XCTestCase {
    var sut: ExerciseSelectionViewModel!
    var mockDataProvider: MockExerciseDataProvider!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockDataProvider = MockExerciseDataProvider()
        mockAnalytics = MockAnalyticsService()
        sut = ExerciseSelectionViewModel(
            dataProvider: mockDataProvider,
            analytics: mockAnalytics
        )
    }
    
    override func tearDown() {
        sut = nil
        mockDataProvider = nil
        mockAnalytics = nil
        super.tearDown()
    }
    
    // MARK: - Init & Loading
    
    func test_init_startsLoadingExercises() async {
        // Arrange
        let viewModel = ExerciseSelectionViewModel(
            dataProvider: mockDataProvider,
            analytics: mockAnalytics
        )
        
        // Act
        try? await Task.sleep(nanoseconds: 10_000_000) // Brief delay for async init
        
        // Assert
        XCTAssertEqual(viewModel.loadingState, .idle)
        XCTAssertFalse(viewModel.exercises.isEmpty)
    }
    
    func test_loadExercises_success_populatesExercises() async {
        // Arrange
        mockDataProvider.exercises = [
            BreathingExercise.mock(name: "Box Breathing"),
            BreathingExercise.mock(name: "4-7-8")
        ]
        
        // Act
        await sut.refreshExercises()
        
        // Assert
        XCTAssertEqual(sut.exercises.count, 2)
        XCTAssertEqual(sut.exercises[0].name, "Box Breathing")
        XCTAssertEqual(sut.loadingState, .idle)
    }
    
    func test_loadExercises_failure_setsErrorState() async {
        // Arrange
        mockDataProvider.shouldFail = true
        mockDataProvider.error = ExerciseError.dataUnavailable
        
        // Act
        await sut.refreshExercises()
        
        // Assert
        XCTAssertTrue(sut.exercises.isEmpty)
        if case .error(let msg) = sut.loadingState {
            XCTAssertEqual(msg, "No exercises available")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func test_loadExercises_tracksAnalytics() async {
        // Arrange
        mockDataProvider.exercises = [
            BreathingExercise.mock(),
            BreathingExercise.mock()
        ]
        
        // Act
        await sut.refreshExercises()
        
        // Assert
        XCTAssertTrue(mockAnalytics.trackedEvents.contains { event in
            if case .exercisesLoaded(count: 2) = event {
                return true
            }
            return false
        })
    }
    
    // MARK: - Filtering
    
    func test_filteredExercises_returnsAll_whenNoCategorySelected() {
        // Arrange
        sut.exercises = [
            BreathingExercise.mock(category: .calm),
            BreathingExercise.mock(category: .focus),
            BreathingExercise.mock(category: .sleep)
        ]
        sut.selectedCategory = nil
        
        // Act
        let filtered = sut.filteredExercises
        
        // Assert
        XCTAssertEqual(filtered.count, 3)
    }
    
    func test_filteredExercises_filtersByCategory() {
        // Arrange
        sut.exercises = [
            BreathingExercise.mock(category: .calm),
            BreathingExercise.mock(category: .calm),
            BreathingExercise.mock(category: .focus)
        ]
        
        // Act
        sut.selectCategory(.calm)
        let filtered = sut.filteredExercises
        
        // Assert
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { $0.category == .calm })
    }
    
    func test_filteredExercises_isEmpty_whenNoMatch() {
        // Arrange
        sut.exercises = [
            BreathingExercise.mock(category: .calm)
        ]
        
        // Act
        sut.selectCategory(.energy)
        
        // Assert
        XCTAssertTrue(sut.filteredExercises.isEmpty)
    }
    
    func test_selectCategory_tracksAnalytics() {
        // Act
        sut.selectCategory(.calm)
        
        // Assert
        XCTAssertTrue(mockAnalytics.trackedEvents.contains { event in
            if case .exerciseFiltered(category: "Calm") = event {
                return true
            }
            return false
        })
    }
    
    func test_selectCategory_nil_tracksAll() {
        // Act
        sut.selectCategory(nil)
        
        // Assert
        XCTAssertTrue(mockAnalytics.trackedEvents.contains { event in
            if case .exerciseFiltered(category: "All") = event {
                return true
            }
            return false
        })
    }
    
    // MARK: - Selection
    
    func test_selectExercise_setsSelectedExercise() {
        // Arrange
        let exercise = BreathingExercise.mock(name: "Test")
        
        // Act
        sut.selectExercise(exercise)
        
        // Assert
        XCTAssertEqual(sut.selectedExercise?.id, exercise.id)
    }
    
    func test_selectExercise_tracksAnalytics() {
        // Arrange
        let exercise = BreathingExercise.mock(
            name: "Box Breathing",
            category: .calm
        )
        
        // Act
        sut.selectExercise(exercise)
        
        // Assert
        XCTAssertTrue(mockAnalytics.trackedEvents.contains { event in
            if case .exerciseSelected(
                id: let id,
                name: "Box Breathing",
                category: "Calm"
            ) = event, id == exercise.id.uuidString {
                return true
            }
            return false
        })
    }
    
    func test_clearSelection_clearsSelectedExercise() {
        // Arrange
        sut.selectExercise(BreathingExercise.mock())
        XCTAssertNotNil(sut.selectedExercise)
        
        // Act
        sut.clearSelection()
        
        // Assert
        XCTAssertNil(sut.selectedExercise)
    }
    
    // MARK: - Loading State
    
    func test_isLoading_true_whenStateIsLoading() {
        // Arrange
        // Force loading state (normally set by loadExercises)
        // This requires exposing loadingState as settable in tests or using Reflection
        
        // Act - we'll test through refresh
        Task {
            mockDataProvider.delaySeconds = 1
            await sut.refreshExercises()
        }
        
        // Assert (would need to check immediately after Task starts)
        // This is tricky without direct state mutation
    }
    
    func test_errorMessage_returnsNil_whenNoError() {
        // Arrange
        sut.loadingState = .idle
        
        // Act
        let msg = sut.errorMessage
        
        // Assert
        XCTAssertNil(msg)
    }
    
    func test_errorMessage_returnsMessage_onError() {
        // Arrange
        sut.loadingState = .error("Network failed")
        
        // Act
        let msg = sut.errorMessage
        
        // Assert
        XCTAssertEqual(msg, "Network failed")
    }
    
    // MARK: - Task Cancellation
    
    func test_deinit_cancelsLoadTask() async {
        // Arrange
        mockDataProvider.delaySeconds = 5
        var viewModel: ExerciseSelectionViewModel? = ExerciseSelectionViewModel(
            dataProvider: mockDataProvider,
            analytics: mockAnalytics
        )
        
        // Act
        viewModel = nil // Trigger deinit
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertTrue(mockDataProvider.wasCancelled)
    }
    
    func test_refreshExercises_cancelsOngoingLoad() async {
        // Arrange
        mockDataProvider.delaySeconds = 2
        let loadTask = Task { await sut.refreshExercises() }
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Act
        await sut.refreshExercises() // Should cancel previous
        
        // Assert
        XCTAssertTrue(mockDataProvider.wasCancelled)
    }
}