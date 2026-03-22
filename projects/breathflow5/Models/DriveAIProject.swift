// DriveAI/Foundation/DriveAIProject.swift
import Foundation

/// Main project configuration and metadata
public struct DriveAIProject {
    public static let shared = DriveAIProject()

    public let id = "driveai"
    public let name = "DriveAI"
    public let platform = "iOS"
    public let description = "Driver's license learning app with spaced repetition and interactive quiz system"
    public let version = "1.0.0"

    private init() {}
}

// DriveAI/Foundation/ExamReadinessScore.swift
import Foundation

/// Exam readiness score calculator based on self-determination theory
/// Provides competence feedback to users about their progress toward exam readiness
public struct ExamReadinessScore: Equatable, Hashable {
    public let score: Int // 0-100
    public let lastUpdated: Date
    public let breakdown: KnowledgeAreaBreakdown

    public struct KnowledgeAreaBreakdown: Equatable, Hashable {
        public let trafficSigns: Double // 20% weight
        public let trafficRules: Double // 30% weight
        public let safetyProcedures: Double // 50% weight

        public init(trafficSigns: Double, trafficRules: Double, safetyProcedures: Double) {
            self.trafficSigns = trafficSigns
            self.trafficRules = trafficRules
            self.safetyProcedures = safetyProcedures
        }
    }

    public init(score: Int, breakdown: KnowledgeAreaBreakdown) {
        self.score = max(0, min(100, score))
        self.breakdown = breakdown
        self.lastUpdated = Date()
    }

    /// Calculate readiness score from quiz performance
    public static func calculate(
        correctAnswers: Int,
        totalQuestions: Int,
        trafficSignsCorrect: Int,
        trafficSignsTotal: Int,
        trafficRulesCorrect: Int,
        trafficRulesTotal: Int,
        safetyCorrect: Int,
        safetyTotal: Int
    ) -> ExamReadinessScore {
        let trafficSignsScore = Double(trafficSignsCorrect) / Double(max(1, trafficSignsTotal)) * 20
        let trafficRulesScore = Double(trafficRulesCorrect) / Double(max(1, trafficRulesTotal)) * 30
        let safetyScore = Double(safetyCorrect) / Double(max(1, safetyTotal)) * 50

        let totalScore = trafficSignsScore + trafficRulesScore + safetyScore
        let roundedScore = Int(totalScore.rounded())

        let breakdown = KnowledgeAreaBreakdown(
            trafficSigns: trafficSignsScore,
            trafficRules: trafficRulesScore,
            safetyProcedures: safetyScore
        )

        return ExamReadinessScore(score: roundedScore, breakdown: breakdown)
    }

    /// Get motivational message based on score
    public var motivationalMessage: String {
        switch score {
        case 0..<20: return "Keep going! Every question is a step closer to your license."
        case 20..<40: return "Good start! Focus on areas where you struggled."
        case 40..<60: return "You're making progress! Review your weak areas."
        case 60..<80: return "Almost there! You're building strong knowledge."
        case 80..<95: return "Excellent work! Just a few more topics to master."
        case 95...100: return "Perfect! You're ready for your exam!"
        default: return "Stay consistent with your practice!"
        }
    }
}

// DriveAI/Foundation/DriveAIFoundation.swift
import Foundation

/// Core foundation layer for DriveAI
public enum DriveAIFoundation {
    /// Register all DriveAI components and services
    public static func register() {
        // Register services
        ServiceRegistry.shared.register(ExamReadinessCalculator.self) {
            ExamReadinessCalculator()
        }

        // Register view models
        ViewModelRegistry.shared.register(QuizViewModel.self) { params in
            QuizViewModel(quizID: params["quizID"] as? String ?? "")
        }

        // Register persistence
        PersistenceService.shared.register(modelType: ExamReadinessScore.self)
    }

    /// Get project configuration
    public static var project: DriveAIProject {
        DriveAIProject.shared
    }
}

// DriveAI/Foundation/ExamReadinessCalculator.swift
import Foundation

/// Calculates and tracks exam readiness over time
public final class ExamReadinessCalculator: ObservableObject {
    @Published public private(set) var currentScore: ExamReadinessScore?
    @Published public private(set) var history: [ExamReadinessScore] = []

    private let persistence: PersistenceService

    public init(persistence: PersistenceService = PersistenceService.shared) {
        self.persistence = persistence
        loadHistory()
    }

    /// Update score after completing a quiz
    public func updateScore(
        correctAnswers: Int,
        totalQuestions: Int,
        trafficSignsCorrect: Int,
        trafficSignsTotal: Int,
        trafficRulesCorrect: Int,
        trafficRulesTotal: Int,
        safetyCorrect: Int,
        safetyTotal: Int
    ) {
        let newScore = ExamReadinessScore.calculate(
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            trafficSignsCorrect: trafficSignsCorrect,
            trafficSignsTotal: trafficSignsTotal,
            trafficRulesCorrect: trafficRulesCorrect,
            trafficRulesTotal: trafficRulesTotal,
            safetyCorrect: safetyCorrect,
            safetyTotal: safetyTotal
        )

        currentScore = newScore
        history.append(newScore)
        saveHistory()
    }

    /// Get progress trend (improving, stable, declining)
    public var progressTrend: ProgressTrend {
        guard history.count >= 2 else { return .stable }

        let recentScores = history.suffix(3).map { $0.score }
        let trend = recentScores[0] - recentScores.last!

        if trend > 5 { return .improving }
        if trend < -5 { return .declining }
        return .stable
    }

    public enum ProgressTrend {
        case improving, stable, declining
    }

    // MARK: - Persistence

    private func loadHistory() {
        history = persistence.load([ExamReadinessScore].self, forKey: "examReadinessHistory") ?? []
        currentScore = history.last
    }

    private func saveHistory() {
        persistence.save(history, forKey: "examReadinessHistory")
    }
}

// DriveAI/Foundation/ServiceRegistry.swift
import Foundation

/// Lightweight service locator for DriveAI
public final class ServiceRegistry {
    public static let shared = ServiceRegistry()

    private var services: [String: () -> Any] = [:]

    private init() {}

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory
    }

    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = services[key], let service = factory() as? T else {
            fatalError("Service \(T.self) not registered")
        }
        return service
    }
}

// DriveAI/Foundation/ViewModelRegistry.swift
import Foundation

/// ViewModel factory registry
public final class ViewModelRegistry {
    public static let shared = ViewModelRegistry()

    private var factories: [String: (Any) -> Any] = [:]

    private init() {}

    public func register<T>(_ type: T.Type, factory: @escaping (Any) -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    public func create<T>(_ type: T.Type, params: Any = ()) -> T {
        let key = String(describing: type)
        guard let factory = factories[key] else {
            fatalError("ViewModel \(T.self) not registered")
        }
        return factory(params) as! T
    }
}

// DriveAI/Foundation/PersistenceService.swift
import Foundation

/// Lightweight persistence service
public final class PersistenceService {
    public static let shared = PersistenceService()

    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to save \(key): \(error)")
        }
    }

    public func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to load \(key): \(error)")
            return nil
        }
    }

    public func register<T: Codable>(modelType: T.Type) {
        // No-op for UserDefaults, but can be extended for other storage
    }
}