// SimulationProtocols.swift
// Single location for all simulation-feature protocols.
// Prevents redeclaration across service files.
//
// Actor isolation requirement:
// All store protocols must be implemented as actors or otherwise
// guarantee safe concurrent reads and serialised writes.
// The recommended pattern is `actor ConcreteStore: StoreProtocol`.

import Foundation

// MARK: - Question Access

protocol QuestionRepositoryProtocol {
    func allQuestions() -> [ExamQuestion]
}

// MARK: - Simulation Persistence

/// Must be actor-isolated. Called from async contexts in ExamSimulationService.
protocol SimulationStoreProtocol {
    func save(_ result: SimulationResult) async throws
    func loadAll() async throws -> [SimulationResult]
}

// MARK: - Readiness Score Persistence

/// Must be actor-isolated. Called concurrently from ReadinessScoreService.compute().
protocol ReadinessScoreStoreProtocol {
    func save(_ score: ReadinessScore) async throws
    func loadLatest() async throws -> ReadinessScore?
    func loadLastScoreBefore(_ date: Date) async throws -> ReadinessScore?
}

// MARK: - Activity Tracking

/// Must be actor-isolated.
/// currentStreakDays() and lastSessionDatePerTopic() are called
/// concurrently from ReadinessScoreService.compute().
protocol ActivityStoreProtocol {
    func currentStreakDays() async throws -> Int
    func sessionCountInLastDays(_ days: Int) async throws -> Int
    func lastSessionDatePerTopic() async throws -> [String: Date]
}

// MARK: - Topic Competence

protocol TopicCompetenceServiceProtocol {
    func allTopicCompetences() async throws -> [String: TopicCompetence]
}

// MARK: - Simulation Service

protocol ExamSimulationServiceProtocol {
    func generateQuestions(for config: SimulationConfig) throws -> [ExamQuestion]
    func evaluate(_ simulation: ExamSimulation, previousScore: Int?) async throws -> SimulationResult
    func save(_ result: SimulationResult) async throws
    func loadHistory() async throws -> [SimulationResult]
    func loadRecentHistory(limit: Int) async throws -> [SimulationResult]
}

// MARK: - Readiness Service

protocol ReadinessScoreServiceProtocol {
    func compute() async throws -> ReadinessScore
    func loadLatest() async throws -> ReadinessScore?
}