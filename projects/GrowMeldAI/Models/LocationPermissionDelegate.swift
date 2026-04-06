private func requestPermissionWithPrompt(
    context: ConsentContext
) async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
        let delegate = LocationPermissionDelegate { [weak self] result in
            self?.permissionState = result ? .authorized : .denied
            continuation.resume(with: .success(result))
        }
        
        let manager = CLLocationManager()
        manager.delegate = delegate
        
        // Retain delegate to prevent deallocation
        objc_setAssociatedObject(
            manager,
            &locationManagerDelegateKey,
            delegate,
            .OBJC_ASSOCIATION_RETAIN
        )
        
        manager.requestWhenInUseAuthorization()
    }
}

// Helper class to bridge CLLocationManager callbacks
private class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
    let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        DispatchQueue.main.async {
            let authorized = manager.authorizationStatus == .authorizedWhenInUse
            self.completion(authorized)
        }
    }
}

private var locationManagerDelegateKey: UInt8 = 0