// Sources/Features/Location/ViewModels/LocationPermissionViewModel.swift
import Combine

@MainActor
final class LocationPermissionViewModel: ObservableObject {
    @Published var permissionStatus: LocationPermissionStatus = .notDetermined
    @Published var isLoading = false
    @Published var error: LocationError?
    
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager = .shared) {
        self.locationManager = locationManager
        self.permissionStatus = locationManager.getCurrentPermissionStatus()
    }
    
    // MARK: - User Actions
    func requestPermission() async {
        isLoading = true
        defer { isLoading = false }
        
        let status = await locationManager.requestWhenInUseAuthorization()
        await MainActor.run {
            self.permissionStatus = status
            
            if status == .denied {
                self.error = .permissionDenied
            } else if status == .restricted {
                self.error = .permissionRestricted
            }
        }
    }
    
    func dismissError() {
        error = nil
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Computed Properties
    var isAuthorized: Bool {
        permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways
    }
    
    var shouldShowPermissionRequest: Bool {
        permissionStatus == .notDetermined
    }
}