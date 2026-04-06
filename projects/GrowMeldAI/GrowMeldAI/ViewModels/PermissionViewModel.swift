import Combine
import Foundation

final class PermissionViewModel: ObservableObject {
    @Published private(set) var status: PermissionFlowDecision = .notDetermined
    @Published private(set) var isRequesting = false
    @Published private(set) var errorMessage: String?

    private let permissionService: CameraPermissionServiceProtocol
    private let logger: LoggerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(permissionService: CameraPermissionServiceProtocol,
         logger: LoggerProtocol = DriveAIDefaultLogger()) {
        self.permissionService = permissionService
        self.logger = logger
        checkStatus()
    }

    @MainActor
    func requestPermission() async {
        isRequesting = true
        errorMessage = nil

        do {
            let decision = try await permissionService.requestCameraPermission()
            status = decision
            logger.log("Camera permission result: \(decision)")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Permission request failed: \(error)")
        }

        isRequesting = false
    }

    func checkStatus() {
        status = permissionService.checkCurrentStatus()
    }

    func clearError() {
        errorMessage = nil
    }
}