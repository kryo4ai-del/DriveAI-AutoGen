// Models/PerformanceStorageServiceProtocol.swift

import Foundation

// MARK: - Supporting Models

struct PerformanceMetrics: Codable, Identifiable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    var correctAnswers: Int
    var totalAttempts: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastAttemptDate: Date?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        categoryName: String,
        correctAnswers: Int = 0,
        totalAttempts: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastAttemptDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.correctAnswers = correctAnswers
        self.totalAttempts = totalAttempts
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastAttemptDate = lastAttemptDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAttempts)
    }
}

struct PerformanceUpdateEvent: Codable, Identifiable {
    let id: UUID
    let questionId: UUID
    let categoryId: UUID
    let isCorrect: Bool
    let difficulty: Double
    let timeSpentSeconds: Int
    let timestamp: Date

    init(
        id: UUID = UUID(),
        questionId: UUID,
        categoryId: UUID,
        isCorrect: Bool,
        difficulty: Double,
        timeSpentSeconds: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.questionId = questionId
        self.categoryId = categoryId
        self.isCorrect = isCorrect
        self.difficulty = difficulty
        self.timeSpentSeconds = timeSpentSeconds
        self.timestamp = timestamp
    }
}

// MARK: - Storage Errors

enum PerformanceStorageError: Error, LocalizedError {
    case initializationFailed(String)
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case recordFailed(String)
    case clearFailed(String)

    var errorDescription: String? {
        switch self {
        case .initializationFailed(let msg): return "Storage initialization failed: \(msg)"
        case .saveFailed(let msg): return "Save failed: \(msg)"
        case .fetchFailed(let msg): return "Fetch failed: \(msg)"
        case .deleteFailed(let msg): return "Delete failed: \(msg)"
        case .recordFailed(let msg): return "Record event failed: \(msg)"
        case .clearFailed(let msg): return "Clear data failed: \(msg)"
        }
    }
}

// MARK: - Protocol

protocol PerformanceStorageServiceProtocol {
    func saveMetrics(_ metrics: PerformanceMetrics) throws
    func fetchMetrics(categoryId: UUID) throws -> PerformanceMetrics?
    func fetchAllMetrics() throws -> [PerformanceMetrics]
    func deleteMetrics(categoryId: UUID) throws
    func recordPerformanceUpdate(_ event: PerformanceUpdateEvent) throws
    func clearAllData() throws
}

// MARK: - In-Memory / UserDefaults-backed Implementation (no SQLite dependency)

actor PerformanceStorageService: PerformanceStorageServiceProtocol {

    // MARK: - Storage Keys

    private enum StorageKey {
        static let metricsPrefix = "perf_metrics_"
        static let allMetricsIds = "perf_all_metrics_ids"
        static let eventsPrefix = "perf_events_"
        static let allEventIds = "perf_all_event_ids"
    }

    // MARK: - In-memory cache

    private var metricsCache: [String: PerformanceMetrics] = [:]
    private var eventsCache: [String: PerformanceUpdateEvent] = [:]

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults

    // MARK: - Init

    init(dbPath: String = "") throws {
        // dbPath kept for API compatibility; storage uses UserDefaults/in-memory
        self.defaults = UserDefaults.standard
        try loadFromPersistence()
    }

    // MARK: - Persistence Helpers

    private func loadFromPersistence() throws {
        // Load metrics
        let metricIds = defaults.stringArray(forKey: StorageKey.allMetricsIds) ?? []
        for metricId in metricIds {
            let key = StorageKey.metricsPrefix + metricId
            if let data = defaults.data(forKey: key),
               let metrics = try? decoder.decode(PerformanceMetrics.self, from: data) {
                metricsCache[metricId] = metrics
            }
        }

        // Load events
        let eventIds = defaults.stringArray(forKey: StorageKey.allEventIds) ?? []
        for eventId in eventIds {
            let key = StorageKey.eventsPrefix + eventId
            if let data = defaults.data(forKey: key),
               let event = try? decoder.decode(PerformanceUpdateEvent.self, from: data) {
                eventsCache[eventId] = event
            }
        }
    }

    private func persistMetrics(_ metrics: PerformanceMetrics) throws {
        let key = metrics.categoryId.uuidString
        let storageKey = StorageKey.metricsPrefix + key
        do {
            let data = try encoder.encode(metrics)
            defaults.set(data, forKey: storageKey)
            var ids = defaults.stringArray(forKey: StorageKey.allMetricsIds) ?? []
            if !ids.contains(key) {
                ids.append(key)
                defaults.set(ids, forKey: StorageKey.allMetricsIds)
            }
        } catch {
            throw PerformanceStorageError.saveFailed(error.localizedDescription)
        }
    }

    private func removePersistedMetrics(categoryId: UUID) {
        let key = categoryId.uuidString
        let storageKey = StorageKey.metricsPrefix + key
        defaults.removeObject(forKey: storageKey)
        var ids = defaults.stringArray(forKey: StorageKey.allMetricsIds) ?? []
        ids.removeAll { $0 == key }
        defaults.set(ids, forKey: StorageKey.allMetricsIds)
    }

    private func persistEvent(_ event: PerformanceUpdateEvent) throws {
        let key = event.id.uuidString
        let storageKey = StorageKey.eventsPrefix + key
        do {
            let data = try encoder.encode(event)
            defaults.set(data, forKey: storageKey)
            var ids = defaults.stringArray(forKey: StorageKey.allEventIds) ?? []
            if !ids.contains(key) {
                ids.append(key)
                defaults.set(ids, forKey: StorageKey.allEventIds)
            }
        } catch {
            throw PerformanceStorageError.recordFailed(error.localizedDescription)
        }
    }

    private func clearAllPersistence() {
        // Remove metrics
        let metricIds = defaults.stringArray(forKey: StorageKey.allMetricsIds) ?? []
        for id in metricIds {
            defaults.removeObject(forKey: StorageKey.metricsPrefix + id)
        }
        defaults.removeObject(forKey: StorageKey.allMetricsIds)

        // Remove events
        let eventIds = defaults.stringArray(forKey: StorageKey.allEventIds) ?? []
        for id in eventIds {
            defaults.removeObject(forKey: StorageKey.eventsPrefix + id)
        }
        defaults.removeObject(forKey: StorageKey.allEventIds)
    }

    // MARK: - Protocol Implementation

    func saveMetrics(_ metrics: PerformanceMetrics) throws {
        metricsCache[metrics.categoryId.uuidString] = metrics
        try persistMetrics(metrics)
    }

    func fetchMetrics(categoryId: UUID) throws -> PerformanceMetrics? {
        return metricsCache[categoryId.uuidString]
    }

    func fetchAllMetrics() throws -> [PerformanceMetrics] {
        return Array(metricsCache.values).sorted { $0.categoryName < $1.categoryName }
    }

    func deleteMetrics(categoryId: UUID) throws {
        metricsCache.removeValue(forKey: categoryId.uuidString)
        removePersistedMetrics(categoryId: categoryId)
    }

    func recordPerformanceUpdate(_ event: PerformanceUpdateEvent) throws {
        eventsCache[event.id.uuidString] = event
        try persistEvent(event)

        // Update related metrics if they exist
        let categoryKey = event.categoryId.uuidString
        if var metrics = metricsCache[categoryKey] {
            metrics = PerformanceMetrics(
                id: metrics.id,
                categoryId: metrics.categoryId,
                categoryName: metrics.categoryName,
                correctAnswers: metrics.correctAnswers + (event.isCorrect ? 1 : 0),
                totalAttempts: metrics.totalAttempts + 1,
                currentStreak: event.isCorrect ? metrics.currentStreak + 1 : 0,
                longestStreak: event.isCorrect
                    ? max(metrics.longestStreak, metrics.currentStreak + 1)
                    : metrics.longestStreak,
                lastAttemptDate: event.timestamp,
                createdAt: metrics.createdAt,
                updatedAt: Date()
            )
            metricsCache[categoryKey] = metrics
            try persistMetrics(metrics)
        }
    }

    func clearAllData() throws {
        metricsCache.removeAll()
        eventsCache.removeAll()
        clearAllPersistence()
    }
}