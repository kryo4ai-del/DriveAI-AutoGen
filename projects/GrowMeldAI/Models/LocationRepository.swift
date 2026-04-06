import Foundation

/// Protocol for location data access
protocol LocationRepository: Sendable {
    /// Resolve a postal code to its region
    /// - Parameters:
    ///   - plz: Postal code string
    ///   - country: Target country
    /// - Returns: Resolved postal code region
    /// - Throws: LocationError if invalid or not found
    func resolvePostalCode(
        _ plz: String,
        country: DACHCountry
    ) async throws -> PostalCodeRegion
    
    /// Get all regions for a federal state
    /// - Parameter state: Federal state/canton
    /// - Returns: Array of postal code regions
    /// - Throws: LocationError if query fails
    func getAllRegionsByState(
        _ state: FederalState
    ) async throws -> [PostalCodeRegion]
    
    /// Search regions by city name (partial match)
    /// - Parameters:
    ///   - city: City name or partial
    ///   - country: Target country
    /// - Returns: Array of matching postal code regions
    /// - Throws: LocationError if query fails
    func searchByCity(
        _ city: String,
        country: DACHCountry
    ) async throws -> [PostalCodeRegion]
    
    /// Get available federal states for a country
    /// - Parameter country: Target country
    /// - Returns: Array of federal states
    func getStatesForCountry(
        _ country: DACHCountry
    ) -> [FederalState]
}