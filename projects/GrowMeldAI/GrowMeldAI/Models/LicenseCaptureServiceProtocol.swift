protocol LicenseCaptureServiceProtocol: AnyObject {
    func validateImageQuality(_ image: UIImage) async -> CameraQualityMetrics
    func processLicenseImage(_ image: UIImage) async throws -> UIImage
    func compressImage(_ image: UIImage, quality: Float) throws -> Data
}