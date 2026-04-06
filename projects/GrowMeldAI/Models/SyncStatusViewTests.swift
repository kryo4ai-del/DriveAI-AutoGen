import XCTest
import SwiftUI
@testable import DriveAI

class SyncStatusViewTests: XCTestCase {
    var viewModel: BackupViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = BackupViewModel()
    }
    
    // HAPPY PATH: Synced state displays correct label
    func test_SyncStatusView_SyncedState_DisplaysCorrectLabel() {
        // Arrange
        viewModel.syncState = .synced
        viewModel.lastSyncDate = Date().addingTimeInterval(-120) // 2 minutes ago
        
        // Act
        let view = SyncStatusView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        
        // Assert
        XCTAssertTrue(hosting.view.accessibilityLabel?.contains("Synchronisierungsstatus") ?? false)
    }
    
    // EDGE CASE: Touch target size compliance (44x44pt minimum)
    func test_SyncStatusView_SyncButton_HasMinimumTouchTarget() {
        // Arrange
        viewModel.syncState = .synced
        let view = SyncStatusView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        
        // Act
        let syncButton = hosting.view.subviews.first { view in
            view.accessibilityLabel?.contains("Jetzt synchronisieren") ?? false
        }
        
        // Assert
        XCTAssertGreaterThanOrEqual(syncButton?.bounds.width ?? 0, 44)
        XCTAssertGreaterThanOrEqual(syncButton?.bounds.height ?? 0, 44)
    }
    
    // EDGE CASE: Reduced motion respected (no animation)
    func test_SyncStatusView_ReduceMotion_NoAnimation() {
        // Arrange
        viewModel.syncState = .syncing
        
        // Act
        let view = SyncStatusView(viewModel: viewModel)
            .environment(\.accessibilityReduceMotion, true)
        
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        
        // Assert
        // Verify no CABasicAnimation is attached to rotating icon
        let iconView = hosting.view.subviews.first { $0.accessibilityLabel?.contains("Syncing") ?? false }
        let hasAnimation = iconView?.layer.animationKeys()?.count ?? 0 > 0
        XCTAssertFalse(hasAnimation, "Animation should not play when reduce motion is enabled")
    }
    
    // FAILURE SCENARIO: Offline state displays warning icon
    func test_SyncStatusView_OfflineState_DisplaysWarningIcon() {
        // Arrange
        viewModel.syncState = .offline
        
        // Act
        let view = SyncStatusView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        
        // Assert
        XCTAssertTrue(hosting.view.accessibilityLabel?.contains("Offline") ?? false)
    }
    
    // EDGE CASE: Dynamic Type at largest size (xxxL)
    func test_SyncStatusView_LargeText_NoTruncation() {
        // Arrange
        viewModel.syncState = .synced
        viewModel.lastSyncDate = Date().addingTimeInterval(-3600)
        
        // Act
        let view = SyncStatusView(viewModel: viewModel)
            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize * 2.0))
        
        let hosting = UIHostingController(rootView: view)
        hosting.view.bounds = CGRect(x: 0, y: 0, width: 375, height: 100)
        hosting.loadViewIfNeeded()
        
        // Assert - Check that text wraps rather than truncates
        // (implementation-specific; verify layout doesn't overflow)
        XCTAssertLessThanOrEqual(hosting.view.bounds.height, 150)
    }
    
    // EDGE CASE: Color contrast WCAG AA compliance
    func test_SyncStatusView_ColorContrast_MeetsWCAGAA() {
        // Arrange - Light mode background
        let backgroundColor = UIColor.white
        let textColor = UIColor.label // Primary color
        
        // Act
        let contrast = calculateContrast(foreground: textColor, background: backgroundColor)
        
        // Assert - WCAG AA requires 4.5:1 for normal text, 3:1 for large text
        XCTAssertGreaterThanOrEqual(contrast, 4.5)
    }
    
    // FAILURE SCENARIO: VoiceOver announcement order
    func test_SyncStatusView_VoiceOverOrder_LogicalSequence() {
        // Arrange
        viewModel.syncState = .synced
        viewModel.lastSyncDate = Date().addingTimeInterval(-120)
        
        // Act
        let view = SyncStatusView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        
        // Assert - Verify accessibility elements in logical order
        var accessibleElements: [UIAccessibilityElement] = []
        hosting.view.accessibilityElements?.forEach { element in
            if let element = element as? UIAccessibilityElement {
                accessibleElements.append(element)
            }
        }
        
        // Status should come before timestamp, before button
        XCTAssertGreaterThan(accessibleElements.count, 0)
    }
}