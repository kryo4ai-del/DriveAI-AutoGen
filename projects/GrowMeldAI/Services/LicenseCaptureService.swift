// ✅ CORRECT
final class LicenseCaptureService: LicenseCaptureServiceProtocol {
    private let processingQueue = DispatchQueue(
        label: "com.driveai.license.processing",
        qos: .userInitiated
    )
    
    nonisolated func processLicenseImage(_ image: UIImage) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: LicenseCaptureError.unknown("Service deallocated"))
                    return
                }
                do {
                    let processed = try self.processOffMainThread(image)
                    DispatchQueue.main.async {
                        continuation.resume(returning: processed)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}