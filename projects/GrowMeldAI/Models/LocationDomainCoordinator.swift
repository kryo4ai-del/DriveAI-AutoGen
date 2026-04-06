// ✅ COMPLETE IMPLEMENTATION
@MainActor
final class LocationDomainCoordinator: ObservableObject {
    @Published var permissionState: LocationPermissionState = .notDetermined
    @Published var currentLocation: UserLocation?
    @Published var currentContext: LocationContext = .unknown
    @Published var examLocation: ExamLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let permissionService: LocationPermissionService
    private let locationDataService: LocationDataService
    private let contextResolver: LocationContextResolver
    private let examLocationRepository: ExamLocationRepository
    
    private var locationUpdateTask: Task<Void, Never>?
    
    init(
        permissionService: LocationPermissionService = .init(),
        locationDataService: LocationDataService? = nil,
        geocodingService: GeocodingService = .init(),
        contextResolver: LocationContextResolver? = nil,
        examLocationRepository: ExamLocationRepository = .shared
    ) {
        self.permissionService = permissionService
        self.locationDataService = locationDataService
            ?? LocationDataService(permissionService: permissionService)
        self.contextResolver = contextResolver
            ?? LocationContextResolver(geocodingService: geocodingService)
        self.examLocationRepository = examLocationRepository
        
        setupBindings()
        Task { await loadExamLocation() }
    }
    
    deinit {
        locationUpdateTask?.cancel()
    }
    
    // MARK: - Public API
    
    func requestLocationPermission() {
        errorMessage = nil
        permissionService.requestLocationPermission()
    }
    
    func startLocationTracking() {
        guard permissionState == .authorizedWhenInUse else {
            errorMessage = "Standortzugriff erforderlich"
            return
        }
        
        permissionService.startUpdatingLocation()
        trackLocationUpdates()
    }
    
    func stopLocationTracking() {
        locationUpdateTask?.cancel()
        locationUpdateTask = nil
        permissionService.stopUpdatingLocation()
    }
    
    func setExamLocation(_ location: ExamLocation) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        await examLocationRepository.store(location)
        self.examLocation = location
    }
    
    // MARK: - Private
    
    private func setupBindings() {
        permissionService.$permissionState
            .assign(to: &$permissionState)
        
        permissionService.$currentLocation
            .assign(to: &$currentLocation)
    }
    
    private func loadExamLocation() async {
        isLoading = true
        self.examLocation = await examLocationRepository.retrieve()
        isLoading = false
    }
    
    private func trackLocationUpdates() {
        locationUpdateTask?.cancel()
        
        locationUpdateTask = Task {
            while !Task.isCancelled {
                if let location = await locationDataService.getCurrentLocation() {
                    let context = await contextResolver.resolveContext(for: location)
                    
                    // Only update if changed
                    if self.currentContext != context {
                        self.currentContext = context
                    }
                }
                
                try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)  // 10s
            }
        }
    }
}