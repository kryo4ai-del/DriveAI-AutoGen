class LicensePlateScannerViewModel: ObservableObject {
    @Published var cameraFrame: UIImage?
    @Published var detectedPlate: String?
    @Published var isProcessing = false
    
    private let cameraService: CameraServiceType
    private let visionService: VisionFrameworkService
    
    init(
        cameraService: CameraServiceType,
        visionService: VisionFrameworkService
    ) {
        self.cameraService = cameraService
        self.visionService = visionService
    }
    
    @MainActor
    func startScanning() async {
        guard await cameraService.requestPermission() else {
            // Handle permission denial — MVP doesn't care
            return
        }
        
        let frames = cameraService.startCapture()
        for await frame in frames {
            isProcessing = true
            detectedPlate = try await visionService.detectLicensePlate(frame)
            isProcessing = false
        }
    }
}