// Tests/ReadinessScoreServiceTests.swift
// DriveAI – AskFin Premium
// Unit tests for ReadinessScoreService.

import XCTest
@testable import AskFinPremium

final class ReadinessScoreServiceTests: XCTestCase {

    // MARK: - SUT & Dependencies

    private var competenceService: MockTopicCompetenceService!
    private var persistenceStore: MockPersistenceStore!
    private var sut: ReadinessScoreService!

    override func setUp() {
        super.setUp()
        competenceService = MockTopicCompetenceService()
        persistenceStore  = MockPersistenceStore()
        sut = ReadinessScoreService(
            competenceService: competenceService,
            persistenceStore: persistenceStore
        )
    }

    override func tearDown() {
        sut = nil
        competenceService = nil
        persistenceStore  = nil
        super.tearDown()
    }

    // MARK: - Factory Helpers

    private func seedCompetence(
        for topic: TopicArea,
        answered: Int,
        correct: Int,
        lastPracticed: Date? = Date()
    ) {
        competenceService.stubbedCompetences[topic] = TopicCompetence(
            topicArea: topic,
            totalAnswered: answered,
            totalCorrect: correct,
            lastPracticed: lastPracticed
        )
    }

    private func seedAll(answered: Int, correct: Int) {
        for topic in TopicArea.allCases {
            seedCompetence(for: topic, answered: answered, correct: correct)
        }
    }

    /// Builds a `ReadinessScore` with fixed values for use as a prior score
    /// in milestone-detection tests. Mirrors the actual memberwise initializer.
    private func makeScore(
        percentage: Double,
        isExamReady: Bool,
        weakTopics: [TopicCompetence] = []
    ) -> ReadinessScore {
        ReadinessScore(
            overallPercentage: percentage,
            topicScores: [],
            weakTopics: weakTopics,
            isExamReady: isExamReady,
            recommendation: "",
            computedAt: Date()
        )
    }

    // MARK: - Score Calculation

    func test_score_isZero_whenNoAnswers() {
        let score = sut.computeCurrentScore()
        XCTAssertEqual(score.overallPercentage, 0, accuracy: 0.001)
    }

    func test_score_is100_whenAllTopicsPerfect() {
        seedAll(answered: 10, correct: 10)
        let score = sut.computeCurrentScore()
        XCTAssertEqual(score.overallPercentage, 100, accuracy: 0.001)
    }

    func test_score_isApproximatelyHalf_whenHalfCorrectAcrossAllTopics() {
        seedAll(answered: 10, correct: 5)
        let score = sut.computeCurrentScore()
        // Weighted average may not be exactly 50 when topic weights differ.
        // ±5 tolerance accommodates weighting variance while catching
        // gross miscalculation.
        XCTAssertEqual(
            score.overallPercentage, 50,
            accuracy: 5.0,
            "Expected ~50 ± 5% when all topics have 50% accuracy"
        )
    }

    func test_score_isNonZeroAndBelow100_whenOnlyOneTopicAnsweredPerfectly() {
        // One perfect topic → above 0. Remaining topics unanswered → below 100.
        seedCompetence(for: .vorfahrt, answered: 10, correct: 10)
        let score = sut.computeCurrentScore()
        XCTAssertGreaterThan(score.overallPercentage, 0)
        XCTAssertLessThan(score.overallPercentage, 100)
    }

    func test_score_increases_afterImprovingWeakTopic() {
        seedAll(answered: 10, correct: 5)
        let baseline = sut.computeCurrentScore()

        seedCompetence(for: .vorfahrt, answered: 20, correct: 20)
        let improved = sut.computeCurrentScore()

        XCTAssertGreaterThan(improved.overallPercentage, baseline.overallPercentage)
    }

    // MARK: - Exam-Ready Threshold

    func test_isExamReady_true_whenScoreWellAboveThreshold() {
        // 90% across all topics should clear any reasonable pass threshold.
        seedAll(answered: 20, correct: 18)
        let score = sut.computeCurrentScore()
        XCTAssertTrue(score.isExamReady)
    }

    func test_isExamReady_false_whenScoreWellBelowThreshold() {
        // 50% across all topics should be well below any pass threshold.
        seedAll(answered: 20, correct: 10)
        let score = sut.computeCurrentScore()
        XCTAssertFalse(score.isExamReady)
    }

    func test_isExamReady_false_whenNoQuestionsAnswered() {
        let score = sut.computeCurrentScore()
        XCTAssertFalse(score.isExamReady)
    }

    // MARK: - Weak Topic Ranking

    func test_weakTopics_sortedByAscendingAccuracy() {
        // Use named cases for stability — avoids dependency on allCases order.
        let seedData: [(TopicArea, Int, Int)] = [
            (.vorfahrt,        9, 10),   // 90%
            (.verkehrszeichen, 3, 10),   // 30%
            (.gefahrenlehre,   6, 10),   // 60%
            (.technisches,     1, 10)    // 10%
        ]
        for (topic, correct, answered) in seedData {
            seedCompetence(for: topic, answered: answered, correct: correct)
        }

        let weakTopics = sut.computeCurrentScore().weakTopics

        guard weakTopics.count >= 2 else {
            XCTFail("Expected at least 2 weak topics, got \(weakTopics.count)")
            return
        }
        for i in 0..<(weakTopics.count - 1) {
            XCTAssertLessThanOrEqual(
                weakTopics[i].accuracyRate,
                weakTopics[i + 1].accuracyRate,
                "weakTopics[\(i)] (\(weakTopics[i].accuracyRate)) " +
                "must be ≤ weakTopics[\(i+1)] (\(weakTopics[i+1].accuracyRate))"
            )
        }
    }

    func test_weakTopics_excludeTopicsWithZeroAnswers() {
        // Only .vorfahrt has answers; all other topics remain at zero.
        seedCompetence(for: .vorfahrt, answered: 5, correct: 1)
        let score = sut.computeCurrentScore()

        for topic in score.weakTopics {
            XCTAssertGreaterThan(
                topic.totalAnswered, 0,
                "Topic \(topic.topicArea) has zero answers and must not appear in weakTopics"
            )
        }
    }

    func test_weakTopics_isEmpty_whenNoQuestionsAnswered() {
        let score = sut.computeCurrentScore()
        XCTAssertTrue(score.weakTopics.isEmpty)
    }

    // MARK: - Milestone Detection

    func test_milestone_examReady_firesOnFirstQualifyingScore() {
        seedAll(answered: 20, correct: 18)
        let score = sut.computeCurrentScore()
        let milestones = sut.detectNewMilestones(for: score, previousScore: nil)
        XCTAssertTrue(
            milestones.contains(.examReady),
            "examReady milestone must fire the first time the score qualifies"
        )
    }

    func test_milestone_examReady_doesNotRefire_whenAlreadyAchieved() {
        seedAll(answered: 20, correct: 18)
        let previous = makeScore(percentage: 90, isExamReady: true)
        let current  = sut.computeCurrentScore()
        let milestones = sut.detectNewMilestones(for: current, previousScore: previous)
        XCTAssertFalse(
            milestones.contains(.examReady),
            "examReady milestone must not re-fire when already achieved"
        )
    }

    func test_milestone_examReady_doesNotFire_whenBelowThreshold() {
        seedAll(answered: 20, correct: 10)
        let score = sut.computeCurrentScore()
        let milestones = sut.detectNewMilestones(for: score, previousScore: nil)
        XCTAssertFalse(milestones.contains(.examReady))
    }

    func test_milestone_firstQuestion_fires_onTransitionFromZeroAnswers() {
        let previous = makeScore(percentage: 0, isExamReady: false)
        seedCompetence(for: .vorfahrt, answered: 1, correct: 1)
        let current = sut.computeCurrentScore()
        let milestones = sut.detectNewMilestones(for: current, previousScore: previous)
        XCTAssertTrue(
            milestones.contains(.firstQuestion),
            "firstQuestion milestone must fire when first answer is recorded"
        )
    }

    func test_milestone_firstQuestion_doesNotRefire_afterSubsequentAnswers() {
        // First call — milestone fires.
        seedCompetence(for: .vorfahrt, answered: 1, correct: 1)
        let firstScore = sut.computeCurrentScore()
        let firstMilestones = sut.detectNewMilestones(
            for: firstScore, previousScore: nil
        )
        XCTAssertTrue(firstMilestones.contains(.firstQuestion))

        // Second call with additional answers — must not fire again.
        seedCompetence(for: .vorfahrt, answered: 5, correct: 4)
        let secondScore    = sut.computeCurrentScore()
        let secondMilestones = sut.detectNewMilestones(
            for: secondScore, previousScore: firstScore
        )
        XCTAssertFalse(
            secondMilestones.contains(.firstQuestion),
            "firstQuestion milestone must not re-fire after already triggering"
        )
    }

    // MARK: - Recommendation

    func test_recommendation_isNotEmpty_whenWeakTopicsExist() {
        seedCompetence(for: .vorfahrt, answered: 10, correct: 1)
        let score = sut.computeCurrentScore()
        XCTAssertFalse(
            score.recommendation.isEmpty,
            "A non-empty recommendation must be generated when weak topics exist"
        )
    }

    func test_recommendation_mentionsWeakestTopicByName() {
        // .technisches seeded at 10% — should be the weakest topic.
        seedCompetence(for: .technisches,     answered: 10, correct: 1)
        seedCompetence(for: .gefahrenlehre,   answered: 10, correct: 7)
        seedCompetence(for: .verkehrszeichen, answered: 10, correct: 8)
        let score = sut.computeCurrentScore()
        XCTAssertTrue(
            score.recommendation.localizedCaseInsensitiveContains(
                TopicArea.technisches.displayName
            ),
            "Recommendation '\(score.recommendation)' should mention " +
            "the weakest topic '\(TopicArea.technisches.displayName)'"
        )
    }

    func test_recommendation_isNotEmpty_whenExamReady() {
        // Even high scorers should receive a message (encouragement or confirmation).
        seedAll(answered: 20, correct: 19)
        let score = sut.computeCurrentScore()
        XCTAssertTrue(score.isExamReady)
        XCTAssertFalse(score.recommendation.isEmpty)
    }

    // MARK: - Persistence

    func test_save_persistsScoreToPersistenceStore() {
        let score = sut.computeCurrentScore()
        sut.save(score)
        XCTAssertNotNil(persistenceStore.lastSavedScore)
        XCTAssertEqual(
            persistenceStore.lastSavedScore?.overallPercentage,
            score.overallPercentage,
            accuracy: 0.001
        )
    }

    func test_save_canBeCalledMultipleTimes_withoutCrash() {
        let score = sut.computeCurrentScore()
        sut.save(score)
        sut.save(score)
        XCTAssertEqual(persistenceStore.savedScores.count, 2)
    }

    func test_loadSavedScore_returnsNil_whenNothingSaved() {
        XCTAssertNil(sut.loadSavedScore())
    }

    func test_loadSavedScore_returnsPreviouslySavedScore() {
        let score = sut.computeCurrentScore()
        sut.save(score)
        persistenceStore.stubbedScore = score      // prime the load stub
        let loaded = sut.loadSavedScore()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(
            loaded?.overallPercentage,
            score.overallPercentage,
            accuracy: 0.001
        )
    }

    // MARK: - Concurrency Safety

    func test_computeCurrentScore_isStable_underConcurrentAccess() {
        seedAll(answered: 10, correct: 7)

        let expectation = expectation(description: "concurrent score computations")
        expectation.expectedFulfillmentCount = 10

        for _ in 0..<10 {
            DispatchQueue.global().async {
                let score = self.sut.computeCurrentScore()
                XCTAssertGreaterThanOrEqual(score.overallPercentage, 0.0)
                XCTAssertLessThanOrEqual(score.overallPercentage, 100.0)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }
}