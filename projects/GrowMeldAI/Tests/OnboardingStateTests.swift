// Tests/OnboardingTests/ModelTests/OnboardingStateTests.swift
import XCTest
@testable import DriveAI

final class OnboardingStateTests: XCTestCase {
    
    func testStateProgression() {
        var state = OnboardingState.welcome
        XCTAssertEqual(state.stepNumber, 1)
        XCTAssertEqual(state.totalSteps, 4)
        
        state = .camera
        XCTAssertEqual(state.stepNumber, 2)
        
        let profile = UserProfile(firstName: "Test", lastName: "User", licenseCategory: .b)
        state = .profileForm(userProfile: profile)
        XCTAssertEqual(state.stepNumber, 3)
        
        state = .confirmation(userProfile: profile)
        XCTAssertEqual(state.stepNumber, 4)
        
        state = .completed(userProfile: profile)
        XCTAssertEqual(state.stepNumber, 5)
    }
    
    func testCanGoBackLogic() {
        XCTAssertFalse(OnboardingState.welcome.canGoBack)
        XCTAssertTrue(OnboardingState.camera.canGoBack)
        
        let profile = UserProfile(firstName: "Test", lastName: "User", licenseCategory: .b)
        XCTAssertTrue(OnboardingState.profileForm(userProfile: profile).canGoBack)
        XCTAssertTrue(OnboardingState.confirmation(userProfile: profile).canGoBack)
    }
    
    func testIsCompletedFlag() {
        let profile = UserProfile(firstName: "Test", lastName: "User", licenseCategory: .b)
        
        XCTAssertFalse(OnboardingState.welcome.isCompleted)
        XCTAssertFalse(OnboardingState.camera.isCompleted)
        XCTAssertTrue(OnboardingState.completed(userProfile: profile).isCompleted)
    }
    
    func testStateEquality() {
        let p1 = UserProfile(firstName: "John", lastName: "Doe", licenseCategory: .b)
        let p2 = UserProfile(firstName: "John", lastName: "Doe", licenseCategory: .b)
        
        let state1 = OnboardingState.profileForm(userProfile: p1)
        let state2 = OnboardingState.profileForm(userProfile: p2)
        
        // Should be equal despite different profile instance timestamps
        XCTAssertEqual(state1, state2)
    }
}