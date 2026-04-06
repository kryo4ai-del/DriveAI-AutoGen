private func validateRegionsAgainstDatabase(
    _ regionData: [RegionManifest.RegionData],
    country: Country
) async throws -> [Region] {
    var validatedRegions: [Region] = []
    
    for data in regionData {
        do {
            // Add timeout wrapper
            let questionCount = try await withTimeout(
                seconds: 5,
                operation: {
                    try await localDataService.questionCount(
                        for: data.id,
                        country: country.id
                    )
                }
            )
            
            guard questionCount > 0 else {
                print("⚠️ Region \(data.name) has no questions")
                continue
            }
            
            validatedRegions.append(...)
        } catch let error as TimeoutError {
            // Log timeout but continue validating other regions
            logger.warning("Timeout validating \(data.name): \(error)")
            // Optionally: skip this region or use cached count
            continue
        } catch {
            logger.error("Failed validating \(data.name): \(error)")
            continue
        }
    }
    
    return validatedRegions
}

// MARK: - Timeout Helper

private func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    let task = Task {
        try await operation()
    }
    
    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    task.cancel()
    
    throw TimeoutError()
}

struct TimeoutError: LocalizedError {
    var errorDescription: String? { "Operation timed out" }
}