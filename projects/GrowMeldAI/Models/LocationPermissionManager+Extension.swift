#if DEBUG
extension LocationPermissionManager {
    static let preview = {
        let manager = LocationPermissionManager()
        manager.permissionStatus = .authorizedWhenInUse
        manager.currentLocation = LocationData(
            latitude: 52.52,
            longitude: 13.405,
            timestamp: Date()
        )
        manager.distanceToExamCenter = DistanceInfo(kilometers: 12.5)
        return manager
    }()
    
    static let denied = {
        let manager = LocationPermissionManager()
        manager.permissionStatus = .denied
        return manager
    }()
}

#Preview {
    LocationPermissionView(permissionManager: .preview)
}
#endif