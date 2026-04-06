// Tests/Models/ExamReadinessTierTests.swift
import XCTest
@testable import DriveAI

class UserProfileReadinessTierTests: XCTestCase {
    var userProfile: UserProfile!
    
    override func setUp() {
        super.setUp()
        userProfile = UserProfile(
            id: UUID(),
            examDate: Date().addingTimeInterval(30 * 24 * 3600),  // 30 days
            overallScoreProgress: 0,
            streakDays: 0,
            categoryProgress: [],
            lastProfileUpdateDate: Date()
        )
    }
    
    // MARK: - Tier Calculation Tests
    
    func testNeedsWorkTier_ScoreBelow60() {
        userProfile.overallScoreProgress = 50
        let tier = userProfile.examReadinessTier
        
        XCTAssertEqual(tier, .needsWork(questionsRemaining: 3))
    }
    
    func testNeedsWorkTier_Exactly59Percent() {
        userProfile.overallScoreProgress = 59
        let tier = userProfile.examReadinessTier
        
        // At 59%, margin to pass is -9 points
        if case .needsWork = tier {
            XCTAssertTrue(true)  // ✅ Correct tier
        } else {
            XCTFail("Expected needsWork tier at 59%")
        }
    }
    
    func testMakingProgressTier_Score60to75_MoreThan14DaysLeft() {
        userProfile.overallScoreProgress = 70
        userProfile.examDate = Date().addingTimeInterval(20 * 24 * 3600)  // 20 days
        
        let tier = userProfile.examReadinessTier
        
        if case .makingProgress(let confidence) = tier {
            XCTAssertEqual(confidence, "wachsen", "Confidence should be 'wachsen' when >14 days left")
        } else {
            XCTFail("Expected makingProgress tier at 70%")
        }
    }
    
    func testMakingProgressTier_Score60to75_LessThan14DaysLeft() {
        userProfile.overallScoreProgress = 72
        userProfile.examDate = Date().addingTimeInterval(10 * 24 * 3600)  // 10 days
        
        let tier = userProfile.examReadinessTier
        
        if case .makingProgress(let confidence) = tier {
            XCTAssertEqual(confidence, "sehr stark", "Confidence should be 'sehr stark' when <14 days left")
        } else {
            XCTFail("Expected makingProgress tier at 72% with 10 days left")
        }
    }
    
    func testAlmostReadyTier_Score75to90() {
        userProfile.overallScoreProgress = 80
        
        let tier = userProfile.examReadinessTier
        
        if case .almostReady = tier {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected almostReady tier at 80%")
        }
    }
    
    func testReadyTier_Score90Plus() {
        userProfile.overallScoreProgress = 95
        
        let tier = userProfile.examReadinessTier
        XCTAssertEqual(tier, .ready)
    }
    
    // MARK: - Edge Cases
    
    func testTierTransition_59to60Percent() {
        userProfile.overallScoreProgress = 59
        let tier59 = userProfile.examReadinessTier
        
        userProfile.overallScoreProgress = 60
        let tier60 = userProfile.examReadinessTier
        
        // At 59, tier should be needsWork
        if case .needsWork = tier59 {
            // At 60, tier should shift to makingProgress
            if case .makingProgress = tier60 {
                XCTAssertTrue(true, "Tier correctly transitions from needsWork to makingProgress")
            } else {
                XCTFail("Tier should shift to makingProgress at 60%")
            }
        } else {
            XCTFail("Expected needsWork at 59%")
        }
    }
    
    func testTierTransition_75to76Percent() {
        userProfile.overallScoreProgress = 75
        let tier75 = userProfile.examReadinessTier
        
        userProfile.overallScoreProgress = 76
        let tier76 = userProfile.examReadinessTier
        
        // At 75, margin to pass is 7 (still makingProgress, 8-15 range is almostReady)
        // At 76, margin to pass is 8 (almostReady)
        if case .almostReady = tier76 {
            XCTAssertTrue(true, "Tier correctly transitions to almostReady at 76%")
        } else {
            XCTFail("Expected almostReady tier at 76%")
        }
    }
    
    // MARK: - Exam Date Boundary Cases
    
    func testTemporalZone_90DaysExactly() {
        userProfile.examDate = Date().addingTimeInterval(90 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .earlyStage)
    }
    
    func testTemporalZone_89DaysLeftShiftsToBuilding() {
        userProfile.examDate = Date().addingTimeInterval(89 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .buildingPhase)
    }
    
    func testTemporalZone_30DaysExactly() {
        userProfile.examDate = Date().addingTimeInterval(30 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .buildingPhase)
    }
    
    func testTemporalZone_29DaysLeftShiftsToFinalPush() {
        userProfile.examDate = Date().addingTimeInterval(29 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .finalPush)
    }
    
    func testTemporalZone_7DaysExactly() {
        userProfile.examDate = Date().addingTimeInterval(7 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .finalPush)
    }
    
    func testTemporalZone_6DaysLeftShiftsToLastMinute() {
        userProfile.examDate = Date().addingTimeInterval(6 * 24 * 3600)
        
        XCTAssertEqual(userProfile.temporalZone, .lastMinute)
    }
    
    func testTemporalZone_ExamDatePast_StaysLastMinute() {
        userProfile.examDate = Date().addingTimeInterval(-5 * 24 * 3600)  // 5 days past
        
        XCTAssertEqual(userProfile.temporalZone, .lastMinute)
        XCTAssertEqual(userProfile.daysUntilExam, 0)  // Clamped to 0
    }
    
    // MARK: - Margin to Pass Calculations
    
    func testMarginToPass_Below68() {
        userProfile.overallScoreProgress = 50
        
        XCTAssertEqual(userProfile.marginToPass, -18)
    }
    
    func testMarginToPass_Exactly68() {
        userProfile.overallScoreProgress = 68
        
        XCTAssertEqual(userProfile.marginToPass, 0)
    }
    
    func testMarginToPass_Above68() {
        userProfile.overallScoreProgress = 85
        
        XCTAssertEqual(userProfile.marginToPass, 17)
    }
}