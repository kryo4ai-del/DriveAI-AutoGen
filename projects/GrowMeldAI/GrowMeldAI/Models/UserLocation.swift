// Domains/LocationDomain/Models/UserLocation.swift
import Foundation
import CoreLocation

struct UserLocation: Equatable, Sendable, Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: CLLocationAccuracy
    let timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        latitude: Double,
        longitude: Double,
        accuracy: CLLocationAccuracy,
        timestamp: Date = Date()
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = timestamp
    }
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.accuracy = location.horizontalAccuracy
        self.timestamp = location.timestamp
    }
}