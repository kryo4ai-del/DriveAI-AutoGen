import Foundation

/// O(16) postal code → Bundesland lookup service (memory-efficient)
/// Loads all 16 Bundesland ranges on demand, zero network calls
@MainActor
final class PLZMappingService {
    static let shared = PLZMappingService()
    
    private let plzRanges: [(start: String, end: String, region: PLZRegion)]
    
    private init() {
        // Build range index from PLZRegion.allRegions (16 entries total)
        // NO enumeration of 90,000 PLZs — just store the ranges
        self.plzRanges = PLZRegion.allRegions.map { region in
            (start: region.plzRangeStart, end: region.plzRangeEnd, region: region)
        }
    }
    
    // MARK: - Public API
    
    /// O(16) lookup: find region for postal code
    /// - Parameter plz: 5-digit postal code (e.g., "80001")
    /// - Returns: Matching PLZRegion or nil if invalid
    nonisolated func region(for plz: String) -> PLZRegion? {
        guard plz.isValidGermanPLZ else { return nil }
        
        // Linear search on 16 ranges (negligible performance impact)
        return plzRanges.first { $0.start <= plz && plz <= $0.end }?.region
    }
    
    /// Returns all 16 Bundesländer, sorted by name
    nonisolated func allRegions() -> [PLZRegion] {
        Array(Set(plzRanges.map { $0.region }))
            .sorted { $0.localizedName < $1.localizedName }
    }
    
    /// Find region by Bundesland ID (e.g., "BY" → Bayern)
    nonisolated func region(byId id: String) -> PLZRegion? {
        plzRanges.first { $0.region.id == id }?.region
    }
    
    // MARK: - Validation
    
    /// Check if PLZ overlaps with any region (sanity check)
    nonisolated func validatePLZRanges() -> [String] {
        var errors: [String] = []
        
        for (i, range1) in plzRanges.enumerated() {
            for (j, range2) in plzRanges.enumerated() where i < j {
                // Check for overlap
                if range1.start <= range2.end && range2.start <= range1.end {
                    errors.append("Overlap: \(range1.region.id) and \(range2.region.id)")
                }
            }
        }
        
        return errors
    }
}