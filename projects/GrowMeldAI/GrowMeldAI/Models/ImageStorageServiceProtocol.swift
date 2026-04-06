// ❌ INCOMPLETE - No implementation provided
protocol ImageStorageServiceProtocol: Sendable {
    func saveLicenseImage(_ imageData: Data, metadata: CapturedLicenseMetadata) async throws -> String
    func retrieveLicenseImage() async throws -> (image: UIImage, metadata: CapturedLicenseMetadata)?
}
// Implementation missing entirely - users can't save photos!