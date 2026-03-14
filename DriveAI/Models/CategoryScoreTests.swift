import XCTest
@testable import DriveAI

final class CategoryScoreTests: XCTestCase {
    
    @Test
    func testPercentageCalculation_Perfect() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 10,
            total: 10
        )
        
        #expect(score.percentage == 1.0)
        #expect(score.performanceLevel == .excellent)
    }
    
    @Test
    func testPercentageCalculation_Good() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 8,
            total: 10
        )
        
        #expect(score.percentage == 0.8)
        #expect(score.performanceLevel == .good)
    }
    
    @Test
    func testPercentageCalculation_Fair() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 7,
            total: 10
        )
        
        #expect(score.percentage == 0.7)
        #expect(score.performanceLevel == .fair)
    }
    
    @Test
    func testPercentageCalculation_NeedsImprovement() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 5,
            total: 10
        )
        
        #expect(score.percentage == 0.5)
        #expect(score.performanceLevel == .needsImprovement)
    }
    
    @Test
    func testPercentageCalculation_Zero() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 0,
            total: 10
        )
        
        #expect(score.percentage == 0.0)
        #expect(score.performanceLevel == .needsImprovement)
    }
    
    @Test
    func testPercentageCalculation_ZeroTotal() {
        let score = CategoryScore(
            categoryId: "signs",
            categoryName: "Verkehrszeichen",
            correct: 0,
            total: 0
        )
        
        #expect(score.percentage == 0.0)  // Guarded division
        #expect(score.performanceLevel == .needsImprovement)
    }
    
    @Test
    func testHashable() {
        let score1 = CategoryScore(
            categoryId: "s1",
            categoryName: "Signs",
            correct: 9,
            total: 10
        )
        
        let score2 = CategoryScore(
            categoryId: "s1",
            categoryName: "Signs",
            correct: 9,
            total: 10
        )
        
        var set = Set<CategoryScore>()
        set.insert(score1)
        set.insert(score2)
        
        // Should only contain 1 because they're equal
        #expect(set.count == 1)
    }
}