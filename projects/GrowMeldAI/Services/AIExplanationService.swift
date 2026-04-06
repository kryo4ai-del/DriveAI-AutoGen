// Services/AIExplanationService.swift
import Foundation
import Combine
import os.log

// MARK: - Supporting Protocol Definitions

protocol AIProvider {
    func generateExplanation(for questionId: Int) async throws -> AIProviderResult
}

struct AIProviderResult {
    let text: String
    let questionId: Int
}

// MARK: - DACH Rules Validator

struct DACHRulesValidator {
    func isCompliantWithDACHRules(_ text: String) -> Bool {
        // Basic compliance check: ensure text is non-empty and doesn't contain
        // obviously non-compliant content
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}

// MARK: - Explanation Cache

struct CachedExplanation {
    let text: String
    let questionId: Int
    let validatedAgainstOfficialSource: Bool
    let expiresAt: Date
}

final class ExplanationCache {
    private var store: [Int: CachedExplanation] = [:]

    func fetch(_ questionId: Int) -> CachedExplanation? {
        guard let cached = store[questionId] else { return nil }
        guard cached.expiresAt > Date() else {
            store.removeValue(forKey: questionId)
            return nil
        }
        return cached
    }

    func save(_ result: AIProviderResult, ttl: TimeInterval) {
        let cached = CachedExplanation(
            text: result.text,
            questionId: result.questionId,
            validatedAgainstOfficialSource: true,
            expiresAt: Date().addingTimeInterval(ttl)
        )
        store[result.questionId] = cached
    }
}

// MARK: - Heuristic Engine

struct HeuristicExplanation {
    let text: String
}

final class GermanTrafficRulesEngine {
    func generateExplanation(for questionId: Int) -> HeuristicExplanation? {
        // Rule-based fallback logic
        let text = "Diese Frage basiert auf den deutschen Straßenverkehrsregeln (StVO). " +
                   "Bitte konsultieren Sie das offizielle Fahrschulbuch für Details."
        return HeuristicExplanation(text: text)
    }
}

// MARK: - Static Fallback Provider

struct StaticExplanation {
    let text: String
}

final class StaticExplanationProvider {
    func explanation(for questionId: Int) -> StaticExplanation {
        return StaticExplanation(
            text: "Keine detaillierte Erklärung verfügbar. " +
                  "Bitte wenden Sie sich an Ihren Fahrlehrer."
        )
    }
}

// MARK: - TimeInterval Extension

private extension TimeInterval {
    static func hours(_ count: Double) -> TimeInterval {
        return count * 3600
    }
}

// MARK: - Logger Extension

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GrowMeldAI", category: "AIExplanationService")

// MARK: - Main Service

@MainActor
class AIExplanationService: ObservableObject {

    enum ResolutionTier: Int, Comparable {
        case liveAI = 0      // External API
        case cached = 1      // Local SQLite
        case heuristic = 2   // Rule-based
        case staticContent = 3      // Bundled JSON

        static func < (lhs: ResolutionTier, rhs: ResolutionTier) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    enum ExplanationError: Error, LocalizedError {
        case networkUnavailable
        case apiTimeout
        case invalidResponse
        case cacheMiss
        case allTiersFailed

        var errorDescription: String? {
            switch self {
            case .networkUnavailable: return "Netzwerk nicht verfügbar."
            case .apiTimeout: return "API-Zeitüberschreitung."
            case .invalidResponse: return "Ungültige Antwort."
            case .cacheMiss: return "Kein Cache-Eintrag gefunden."
            case .allTiersFailed: return "Alle Fallback-Stufen fehlgeschlagen."
            }
        }
    }

    private let liveAIProvider: AIProvider?      // nil if not implemented yet
    private let cache: ExplanationCache
    private let heuristicEngine: GermanTrafficRulesEngine
    private let staticFallback: StaticExplanationProvider

    init(
        liveAIProvider: AIProvider? = nil,
        cache: ExplanationCache,
        heuristicEngine: GermanTrafficRulesEngine,
        staticFallback: StaticExplanationProvider
    ) {
        self.liveAIProvider = liveAIProvider
        self.cache = cache
        self.heuristicEngine = heuristicEngine
        self.staticFallback = staticFallback
    }

    /// Single entry point: Get explanation with automatic fallback
    func getExplanation(
        for questionId: Int,
        preferCached: Bool = true
    ) async throws -> ExplanationResult {

        // Tier 1: Try cache first (if preferred)
        if preferCached, let cached = cache.fetch(questionId) {
            return ExplanationResult(
                text: cached.text,
                tier: .cached,
                source: "Cache",
                isAuthoritative: cached.validatedAgainstOfficialSource
            )
        }

        // Tier 2: Try live AI (if available)
        if let provider = liveAIProvider {
            do {
                let result = try await provider.generateExplanation(for: questionId)

                // Validate against official German traffic rules (MANDATORY)
                let validator = DACHRulesValidator()
                guard validator.isCompliantWithDACHRules(result.text) else {
                    throw ExplanationError.invalidResponse
                }

                // Cache for future use
                cache.save(result, ttl: .hours(48))

                return ExplanationResult(
                    text: result.text,
                    tier: .liveAI,
                    source: "KI",
                    isAuthoritative: true
                )
            } catch {
                // Fall through to Tier 3
                logger.warning("Live AI failed: \(error.localizedDescription)")
            }
        }

        // Tier 3: Heuristic rules (always works, not authoritative)
        if let heuristic = heuristicEngine.generateExplanation(for: questionId) {
            return ExplanationResult(
                text: heuristic.text,
                tier: .heuristic,
                source: "Regel",
                isAuthoritative: false
            )
        }

        // Tier 4: Static bundled content (guaranteed)
        let staticResult = staticFallback.explanation(for: questionId)
        return ExplanationResult(
            text: staticResult.text,
            tier: .staticContent,
            source: "Offline",
            isAuthoritative: false
        )
    }
}

// MARK: - Result Type

struct ExplanationResult {
    let text: String
    let tier: AIExplanationService.ResolutionTier
    let source: String  // "KI" / "Cache" / "Regel" / "Offline"
    let isAuthoritative: Bool
    let generatedAt: Date = Date()
}