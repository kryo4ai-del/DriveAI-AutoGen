// Features/CameraOnboarding/Data/Repositories/LicenseCaptureRepository.swift
import UIKit

@MainActor
final class LicenseCaptureRepository {
    private let captureService: LicenseCaptureServiceProtocol
    private let storageService: ImageStorageServiceProtocol
    
    init(
        captureService: LicenseCaptureServiceProtocol,
        storageService: ImageStorageServiceProtocol
    ) {
        self.captureService = captureService
        self.storageService = storageService
    }
    
    func requestCameraPermission() async throws -> PermissionFlowDecision {
        let isGranted = try await captureService.requestCameraAccess()
        return PermissionFlowDecision(isGranted: isGranted, timestamp: Date())
    }
    
    func processAndStoreLicense(_ image: UIImage) async throws -> CapturedLicenseImage {
        // Validate quality
        let metrics = captureService.validateImageQuality(image)
        guard metrics.qualityScore > 0.7 else {
            throw LicenseCaptureError.poorQuality(metrics)
        }
        
        // Process and compress
        let processed = try await captureService.processLicenseImage(image)
        
        // Store locally
        try await storageService.saveLicenseImage(image, metadata: processed)
        
        return processed
    }
}