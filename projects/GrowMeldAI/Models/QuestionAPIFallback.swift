// Services/APIFallback/QuestionAPIFallback.swift
import Foundation

@MainActor
final class QuestionAPIFallback: APIFallbackStrategy {
    typealias T = [Question]
    
    private let networkMonitor: NetworkMonitor
    private let localDataService: LocalDataService
    private let logger: AppLogger
    
    init(
        networkMonitor: NetworkMonitor,
        localDataService: LocalDataService,
        logger: AppLogger = .shared
    ) {
        self.networkMonitor = networkMonitor
        self.localDataService = localDataService
        self.logger = logger
    }
    
    func fetchWithFallback() async throws -> [Question] {
        if networkMonitor.isConnected {
            do {
                // Attempt remote fetch (placeholder for future API)
                let questions = try await fetchRemoteQuestions()
                await cacheResult(questions)
                logger.info("Questions fetched from remote and cached")
                return questions
            } catch {
                logger.warning("Remote fetch failed, falling back to cache: \(error)")
                if let cached = try await retrieveCached() {
                    return cached
                }
                throw APIError.networkAndCacheUnavailable
            }
        } else {
            logger.info("Offline mode: attempting to load cached questions")
            guard let cached = try await retrieveCached() else {
                throw APIError.offlineNoCacheAvailable
            }
            return cached
        }
    }
    
    func cacheResult(_ data: [Question]) async throws {
        try await localDataService.saveQuestions(data, metadata: CacheMetadata.now)
        logger.info("Cached \(data.count) questions")
    }
    
    func retrieveCached() async throws -> [Question]? {
        let questions = try await localDataService.loadQuestions()
        let metadata = try await localDataService.loadCacheMetadata()
        
        if let metadata = metadata, metadata.isExpired {
            logger.warning("Cache expired at \(metadata.expiresAt)")
            throw APIError.cacheExpired
        }
        
        return questions
    }
    
    // Placeholder for future remote API
    private func fetchRemoteQuestions() async throws -> [Question] {
        // Will integrate with actual API post-MVP
        throw APIError.unknown("Remote API not yet implemented")
    }
}