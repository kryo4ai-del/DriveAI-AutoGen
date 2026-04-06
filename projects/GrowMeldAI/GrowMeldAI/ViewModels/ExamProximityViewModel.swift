@MainActor
final class ExamProximityViewModel: ObservableObject {
    @Published var nearestCenter: ExamCenter?
    @Published var distance: Double?
    @Published var eta: Int?
    
    private let locationManager: LocationManagerProtocol
    private let examService: ExamCenterServiceProtocol
    
    func fetchNearestCenter() async {
        // 1. Get permission + current location
        let location = try await getCurrentLocation()
        
        // 2. Fetch exam centers
        let centers = try await examService.fetchExamCenters()
        
        // 3. Find nearest + calculate distance
        let (nearest, dist) = findNearest(location, in: centers)
        
        self.nearestCenter = nearest
        self.distance = dist
        self.eta = Int(dist / 1.33 / 80 * 60)  // ETA estimate
    }
}