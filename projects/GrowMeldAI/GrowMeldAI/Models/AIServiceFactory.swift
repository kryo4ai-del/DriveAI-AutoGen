import Foundation
import os.log

private let logger = Logger(subsystem: "com.driveai.fallback", category: "factory")

/// Factory for creating AI service instances with fallback configuration
final class AIServiceFactory {
    private init() {}

    /// Create production AI fallback service with all providers
    @MainActor
    static func makeAIFallbackService(
        configuration: FallbackConfiguration = .default,
        primaryService: AIServiceProtocol? = nil
    ) -> AIFallbackService {
        logger.info("Creating AIFallbackService with configuration: \(configuration.strategy)")

        let localProvider = LocalOfflineProvider(bundle: .main)
        let degradedProvider = DegradedModeProvider(localProvider: localProvider)
        let staticProvider = StaticProvider()

        let primary: AIServiceProtocol = primaryService ?? degradedProvider

        let fallbackChain: [FallbackProvider] = [
            localProvider,
            degradedProvider,
            staticProvider
        ]

        let cache = AIResponseCache(maxSizeMB: configuration.maxCacheSizeMB)
        let healthCheck = HealthCheckService(configuration: configuration)

        let service = AIFallbackService(
            primary: primary,
            fallbackChain: fallbackChain,
            cache: cache,
            healthCheck: healthCheck,
            configuration: configuration
        )

        // Setup cache persistence if configured
        if configuration.persistCache {
            let cachePath = FileManager.default
                .urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("ai_response_cache.json")

            do {
                try cache.load(from: cachePath)
                logger.info("Loaded persistent cache from disk")
            } catch {
                logger.warning("Could not load persistent cache: \(error.localizedDescription)")
            }
        }

        return service
    }

    /// Create service for testing with mock primary service
    @MainActor
    static func makeTestService(
        mockPrimary: AIServiceProtocol,
        configuration: FallbackConfiguration = .default
    ) -> AIFallbackService {
        logger.info("Creating test AIFallbackService")
        return makeAIFallbackService(
            configuration: configuration,
            primaryService: mockPrimary
        )
    }

    /// Create minimal service (offline-only, no primary)
    @MainActor
    static func makeOfflineService(
        configuration: FallbackConfiguration = .default
    ) -> AIFallbackService {
        logger.info("Creating offline-only AIFallbackService")

        let mockPrimary = OfflineOnlyMockService()
        return makeAIFallbackService(
            configuration: configuration,
            primaryService: mockPrimary
        )
    }
}

// MARK: - Mock Service for Testing

/// Mock service that always fails (for testing fallback chains)
private final class OfflineOnlyMockService: AIServiceProtocol {
    func getExplanation(for questionID: String) async throws -> String {
        throw OfflineServiceError.offline
    }

    func getQuestions(category: String) async throws -> [LocalQuestion] {
        throw OfflineServiceError.offline
    }

    func getRandomQuestions(count: Int) async throws -> [LocalQuestion] {
        throw OfflineServiceError.offline
    }

    func search(query: String) async throws -> [LocalQuestion] {
        throw OfflineServiceError.offline
    }
}

private enum OfflineServiceError: LocalizedError {
    case offline

    var errorDescription: String? {
        "Service is offline"
    }
}