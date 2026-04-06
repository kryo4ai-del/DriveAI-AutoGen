// Tests/ViewModels/CategoryViewModelTests.swift
import XCTest
@testable import DriveAI

final class CategoryViewModelTests: XCTestCase {
    var viewModel: CategoryViewModel!
    var mockDataService: MockLocalDataService!
    var mockProgressService: MockProgressService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        mockProgressService = MockProgressService()
        viewModel = CategoryViewModel(
            dataService: mockDataService,
            progressService: mockProgressService
        )
    }
    
    // MARK: - Happy Path: Load Categories with Progress
    func test_loadCategories_displaysAllCategoriesWithProgress() {
        // Arrange
        let mockCategories = [
            Category(
                id: 1,
                name: "Verkehrszeichen",
                questionCount: 50,
                icon: "traffic_sign"
            ),
            Category(
                id: 2,
                name: "Vorfahrtsregeln",
                questionCount: 40,
                icon: "priority"
            ),
        ]
        mockDataService.mockCategories = mockCategories
        mockProgressService.mockProgress = [
            1: CategoryProgress(categoryId: 1, completedCount: 25, masteredCount: 15),
            2: CategoryProgress(categoryId: 2, completedCount: 10, masteredCount: 5),
        ]
        
        // Act
        viewModel.loadCategories()
        
        // Assert
        XCTAssertEqual(viewModel.categories.count, 2)
        XCTAssertEqual(viewModel.categories[0].progress?.completedCount, 25)
        XCTAssertEqual(viewModel.categories[0].progressPercentage, 50)  // 25/50
    }
    
    // MARK: - Edge Case: No Progress Data
    func test_loadCategories_withNoProgress_showsZeroProgress() {
        // Arrange
        let mockCategories = [
            Category(
                id: 1,
                name: "Verkehrszeichen",
                questionCount: 50,
                icon: "traffic_sign"
            ),
        ]
        mockDataService.mockCategories = mockCategories
        mockProgressService.mockProgress = [:]  // ← No data
        
        // Act
        viewModel.loadCategories()
        
        // Assert
        XCTAssertEqual(viewModel.categories[0].progressPercentage, 0)
        XCTAssertEqual(viewModel.categories[0].progress?.completedCount, 0)
    }
    
    // MARK: - Sorting: Recommend Incomplete Categories
    func test_sortCategories_prioritizeIncompleteCategories() {
        // Arrange
        let mockCategories = [
            Category(id: 1, name: "Category A", questionCount: 50, icon: "a"),
            Category(id: 2, name: "Category B", questionCount: 50, icon: "b"),
            Category(id: 3, name: "Category C", questionCount: 50, icon: "c"),
        ]
        mockDataService.mockCategories = mockCategories
        mockProgressService.mockProgress = [
            1: CategoryProgress(categoryId: 1, completedCount: 50, masteredCount: 50),  // Completed
            2: CategoryProgress(categoryId: 2, completedCount: 25, masteredCount: 10),  // Incomplete
            3: CategoryProgress(categoryId: 3, completedCount: 0, masteredCount: 0),    // Not started
        ]
        
        // Act
        viewModel.loadCategories()
        viewModel.sortByRecommendation()
        
        // Assert
        XCTAssertEqual(viewModel.sortedCategories[0].id, 3)  // Not started (priority)
        XCTAssertEqual(viewModel.sortedCategories[1].id, 2)  // Incomplete
        XCTAssertEqual(viewModel.sortedCategories[2].id, 1)  // Completed (lowest priority)
    }
    
    // MARK: - Failure: Database Error
    func test_loadCategories_withDatabaseError_showsErrorAlert() {
        // Arrange
        mockDataService.shouldThrowError = true
        mockDataService.mockError = DataServiceError.corruptedDatabase
        
        // Act
        viewModel.loadCategories()
        
        // Assert
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(viewModel.errorMessage, "Database is corrupted. Please reinstall the app.")
    }
    
    // MARK: - Refresh Logic
    func test_refreshCategories_reloadsProgressData() {
        // Arrange
        let initialProgress = mockProgressService.mockProgress
        
        // Act
        viewModel.loadCategories()
        mockProgressService.mockProgress[1]?.completedCount = 30  // Simulate progress update
        viewModel.refreshCategories()
        
        // Assert
        XCTAssertEqual(viewModel.categories[0].progress?.completedCount, 30)
    }
}