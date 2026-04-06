// Domains/LocationDomain/Models/UserLocation+Calculations.swift
import CoreLocation

extension UserLocation {
    func distance(to other: UserLocation) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
    
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func formattedDistance(to coordinate: CLLocationCoordinate2D) -> String {
        let meters = distance(to: coordinate)
        
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.1f km", meters / 1000)
        }
    }
}