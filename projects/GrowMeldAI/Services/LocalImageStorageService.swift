// ✅ COMPLETE - Production-ready storage
final class LocalImageStorageService: ImageStorageServiceProtocol {
    private let fileManager = FileManager.default
    private let licenseImageFileName = "license_photo.jpg"
    private let metadataFileName = "license_metadata.json"
    
    private var storagePath: URL {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("No documents directory available")
        }
        return documentsPath.appendingPathComponent("CameraOnboarding", isDirectory: true)
    }
    
    nonisolated func saveLicenseImage(_ imageData: Data, metadata: CapturedLicenseMetadata) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: LicenseCaptureError.unknown("Service deallocated"))
                    return
                }
                
                do {
                    // Create directory if needed
                    try self.fileManager.createDirectory(at: self.storagePath, withIntermediateDirectories: true, attributes: nil)
                    
                    // Save image
                    let imagePath = self.storagePath.appendingPathComponent(self.licenseImageFileName)
                    try imageData.write(to: imagePath, options: .atomic)
                    
                    // Save metadata
                    let metadataPath = self.storagePath.appendingPathComponent(self.metadataFileName)
                    let metadataData = try JSONEncoder().encode(metadata)
                    try metadataData.write(to: metadataPath, options: .atomic)
                    
                    DispatchQueue.main.async {
                        continuation.resume(returning: imagePath.path)
                    }
                } catch {
                    DispatchQueue.main.async {
                        continuation.resume(throwing: LicenseCaptureError.storageFailure(error.localizedDescription))
                    }
                }
            }
        }
    }
    
    nonisolated func retrieveLicenseImage() async throws -> (image: UIImage, metadata: CapturedLicenseMetadata)? {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: LicenseCaptureError.unknown("Service deallocated"))
                    return
                }
                
                do {
                    let imagePath = self.storagePath.appendingPathComponent(self.licenseImageFileName)
                    let metadataPath = self.storagePath.appendingPathComponent(self.metadataFileName)
                    
                    guard self.fileManager.fileExists(atPath: imagePath.path),
                          self.fileManager.fileExists(atPath: metadataPath.path) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let imageData = try Data(contentsOf: imagePath)
                    let metadataData = try Data(contentsOf: metadataPath)
                    
                    guard let image = UIImage(data: imageData) else {
                        throw LicenseCaptureError.invalidImage
                    }
                    
                    let metadata = try JSONDecoder().decode(CapturedLicenseMetadata.self, from: metadataData)
                    
                    continuation.resume(returning: (image, metadata))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    nonisolated func deleteLicenseImage() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: LicenseCaptureError.unknown("Service deallocated"))
                    return
                }
                
                do {
                    try self.fileManager.removeItem(at: self.storagePath)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: LicenseCaptureError.storageFailure(error.localizedDescription))
                }
            }
        }
    }
    
    nonisolated func licenseImageExists() async -> Bool {
        let imagePath = storagePath.appendingPathComponent(licenseImageFileName)
        return FileManager.default.fileExists(atPath: imagePath.path)
    }
}