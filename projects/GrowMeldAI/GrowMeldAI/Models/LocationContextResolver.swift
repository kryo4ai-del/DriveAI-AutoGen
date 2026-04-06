// Domains/LocationDomain/Services/LocationContextResolver.swift
import CoreLocation
import Foundation

final class LocationContextResolver {
    private let geocodingService: GeocodingService
    
    init(geocodingService: GeocodingService) {
        self.geocodingService = geocodingService
    }
    
    // MARK: - Public API
    
    func resolveContext(for location: UserLocation) async -> LocationContext {
        let region = await geocodingService.reverseGeocode(
            coordinate: location.coordinate
        )
        return region.context
    }
    
    func resolveContext(for coordinate: CLLocationCoordinate2D) async -> LocationContext {
        let region = await geocodingService.reverseGeocode(coordinate: coordinate)
        return region.context
    }
}