import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - Supporting Types

enum LicenseCaptureState {
    case initial
    case permissionNeeded
    case capturing
    case confirmed
    case error
}

protocol LicenseCaptureRepository {
    func requestCameraPermission() async throws -> CameraPermissionDecision
    func processAndStoreLicense(_ image: UIImage) async throws -> CapturedLicenseImage
}

struct CameraPermissionDecision {
    let isGranted: Bool
}

struct CapturedLicenseImage {
    let id: UUID
    let image: UIImage
    let capturedAt: Date
}

// MARK: - DIContainer

final class DIContainer {
    private var factories: [ObjectIdentifier: () -> Any] = [:]

    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)], let instance = factory() as? T else {
            fatalError("DIContainer: No registration found for \(type)")
        }
        return instance
    }
}

// MARK: - ViewModel

@MainActor
final class CameraOnboardingViewModel: ObservableObject {
    @Published var currentState: LicenseCaptureState = .initial
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let repository: LicenseCaptureRepository

    init(repository: LicenseCaptureRepository) {
        self.repository = repository
    }

    func requestPermission() async {
        do {
            let decision = try await repository.requestCameraPermission()
            currentState = decision.isGranted ? .capturing : .permissionNeeded
        } catch {
            errorMessage = "Kamera-Berechtigung erforderlich"
            currentState = .error
        }
    }

    func captureImage(_ image: UIImage) async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await repository.processAndStoreLicense(image)
            currentState = .confirmed
            await notifyPostCaptureEngagement()
        } catch {
            errorMessage = error.localizedDescription
            currentState = .error
        }
    }

    private func notifyPostCaptureEngagement() async {}
}

// MARK: - View

struct CameraOnboardingView: View {
    @ObservedObject var viewModel: CameraOnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            switch viewModel.currentState {
            case .initial:
                Text("Willkommen")
                    .font(.title)
                Button("Kamera-Berechtigung anfragen") {
                    Task { await viewModel.requestPermission() }
                }
            case .permissionNeeded:
                Text("Kamera-Berechtigung erforderlich")
                    .foregroundColor(.red)
            case .capturing:
                Text("Kamera aktiv")
            case .confirmed:
                Text("Erfolgreich erfasst")
                    .foregroundColor(.green)
            case .error:
                Text(viewModel.errorMessage ?? "Unbekannter Fehler")
                    .foregroundColor(.red)
            }

            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}

// MARK: - Coordinator

@MainActor
final class CameraOnboardingCoordinator {
    weak var navigationController: UINavigationController?
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        let viewModel = container.resolve(CameraOnboardingViewModel.self)
        let view = CameraOnboardingView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}