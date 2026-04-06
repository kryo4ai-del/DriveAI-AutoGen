// Services/LocalDataService+DES.swift
import Foundation

extension LocalDataService {
    
    // MARK: - Diagnostic Profile Persistence
    
    func saveDiagnosticProfile(_ profile: UserDiagnosticProfile) async throws {
        let encoded = try JSONEncoder().encode(profile)
        UserDefaults.standard.set(encoded, forKey: "UserDiagnosticProfile")
    }
    
    func loadDiagnosticProfile() async throws -> UserDiagnosticProfile? {
        guard let data = UserDefaults.standard.data(forKey: "UserDiagnosticProfile") else {
            return nil
        }
        return try JSONDecoder().decode(UserDiagnosticProfile.self, from: data)
    }
    
    // MARK: - Performance Metrics (Append-only log)
    
    func appendPerformanceMetrics(_ metrics: PerformanceMetrics) async throws {
        var history = try await loadPerformanceHistory()
        history.append(metrics)
        
        let encoded = try JSONEncoder().encode(history)
        UserDefaults.standard.set(encoded, forKey: "PerformanceMetricsHistory")
    }
    
    func loadPerformanceHistory() async throws -> [PerformanceMetrics] {
        guard let data = UserDefaults.standard.data(forKey: "PerformanceMetricsHistory") else {
            return []
        }
        return try JSONDecoder().decode([PerformanceMetrics].self, from: data)
    }
    
    func loadPerformanceMetrics(for categoryId: String, last7Days: Bool = false) async throws -> [PerformanceMetrics] {
        var metrics = try await loadPerformanceHistory()
        metrics = metrics.filter { $0.categoryId == categoryId }
        
        if last7Days {
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            metrics = metrics.filter { $0.date > sevenDaysAgo }
        }
        
        return metrics.sorted { $0.date < $1.date }
    }
    
    // MARK: - Misconception Registry
    
    func saveMisconceptions(_ misconceptions: [Misconception]) async throws {
        let encoded = try JSONEncoder().encode(misconceptions)
        UserDefaults.standard.set(encoded, forKey: "MisconceptionRegistry")
    }
    
    func loadMisconceptions() async throws -> [Misconception] {
        guard let data = UserDefaults.standard.data(forKey: "MisconceptionRegistry") else {
            return []
        }
        return try JSONDecoder().decode([Misconception].self, from: data)
    }
    
    // MARK: - Recommendation History
    
    func appendRecommendation(_ recommendation: Recommendation) async throws {
        var history = try await loadRecommendationHistory()
        history.append(recommendation)
        
        let encoded = try JSONEncoder().encode(history)
        UserDefaults.standard.set(encoded, forKey: "RecommendationHistory")
    }
    
    func loadRecommendationHistory() async throws -> [Recommendation] {
        guard let data = UserDefaults.standard.data(forKey: "RecommendationHistory") else {
            return []
        }
        return try JSONDecoder().decode([Recommendation].self, from: data)
    }
    
    // MARK: - Clean Start
    
    func resetDESData() async throws {
        UserDefaults.standard.removeObject(forKey: "UserDiagnosticProfile")
        UserDefaults.standard.removeObject(forKey: "PerformanceMetricsHistory")
        UserDefaults.standard.removeObject(forKey: "MisconceptionRegistry")
        UserDefaults.standard.removeObject(forKey: "RecommendationHistory")
    }
}