import XCTest
import SwiftUI
@testable import DriveAI

class ImageImportViewModelTests: XCTestCase {
    
    var viewModel: ImageImportViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ImageImportViewModel()
    }
    
    func testImportImageSuccess() {
        // Arrange
        let image = UIImage(named: "example_sign")!
        
        // Act
        viewModel.importImage(image)
        
        // Assert
        XCTAssertNotNil(viewModel.selectedImage)
        XCTAssertNotNil(viewModel.analysisResult)
    }
    
    func testImportImageFailure() {
        // Simulate failure cases by altering service methods accordingly
        // Use a mock or modified service for edge cases in analysis
        viewModel.imageAnalysisService = MockImageAnalysisService() // assuming you create this
        let image = UIImage(named: "unknown_sign")!
        
        // Act
        viewModel.importImage(image)
        
        // Assert
        XCTAssertNil(viewModel.analysisResult)
        XCTAssertNotNil(viewModel.errorMessage) // Ensure error state is communicated
    }
}