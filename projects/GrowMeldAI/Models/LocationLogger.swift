enum LocationLogger {
    static func debug(_ message: String) {
        #if DEBUG
        print("[Location] DEBUG: \(message)")
        #endif
    }
    
    static func error(_ error: Error, context: String) {
        print("[Location] ERROR in \(context): \(error.localizedDescription)")
    }
}

// Usage:
func lookupPostalCode(_ plz: String) async throws -> PostalCodeRegion {
    LocationLogger.debug("Looking up PLZ: \(plz)")
    
    do {
        let region = try await dataService.getRegion(plz: plz)
        LocationLogger.debug("Found region: \(region.name)")
        return region
    } catch {
        LocationLogger.error(error, context: "lookupPostalCode")
        throw error
    }
}