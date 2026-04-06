// Domains/LocationDomain/Models/GeoRegion.swift
import CoreLocation
import Foundation

struct GeoRegion: Equatable, Sendable, Codable {
    let name: String
    let centerLatitude: Double
    let centerLongitude: Double
    let radiusKilometers: Double
    let context: LocationContext
    let country: String // "DE", "AT", "CH"
    
    var centerCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: centerLatitude,
            longitude: centerLongitude
        )
    }
    
    var radiusMeters: CLLocationDistance {
        radiusKilometers * 1000
    }
    
    static let unknown = GeoRegion(
        name: "Unbekannt",
        centerLatitude: 0,
        centerLongitude: 0,
        radiusKilometers: 0,
        context: .unknown,
        country: "DE"
    )
    
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let regionLocation = CLLocation(
            latitude: centerLatitude,
            longitude: centerLongitude
        )
        let targetLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        let distance = regionLocation.distance(from: targetLocation)
        return distance <= radiusMeters
    }
}