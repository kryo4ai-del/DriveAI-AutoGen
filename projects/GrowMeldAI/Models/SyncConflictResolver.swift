// Services/Firestore/SyncConflictResolver.swift
final class SyncConflictResolver {
    enum ResolutionStrategy {
        case cloudFirst  // Cloud wins
        case localFirst  // Local wins if newer
        case timestamp   // Latest timestamp wins (recommended)
    }
    
    func resolve(
        local: UserProfile,
        cloud: UserProfile,
        strategy: ResolutionStrategy = .timestamp
    ) -> UserProfile {
        switch strategy {
        case .cloudFirst:
            return cloud
        case .localFirst:
            return local.updatedAt > cloud.updatedAt ? local : cloud
        case .timestamp:
            return max(local, cloud, by: { $0.updatedAt < $1.updatedAt })
        }
    }
}