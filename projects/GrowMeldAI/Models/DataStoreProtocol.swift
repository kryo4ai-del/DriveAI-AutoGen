// ❌ Protocol declared but never implemented
protocol DataStoreProtocol {
    func deleteAllUserData(userId: UUID) async throws
}

// ❌ DeletionService assumes it exists

// ❌ App can't even build