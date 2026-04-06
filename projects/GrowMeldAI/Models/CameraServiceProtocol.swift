import Foundation
import AVFoundation

enum CameraState {
    case idle
    case running
    case stopped
    case error(Error)
}

struct PlantIdentity: Codable, Identifiable {
    let id: UUID
    let name: String
    let scientificName: String
    let identifiedAt: Date

    init(id: UUID = UUID(), name: String, scientificName: String, identifiedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.scientificName = scientificName
        self.identifiedAt = identifiedAt
    }
}

protocol CameraServiceProtocol: AnyObject {
    var state: CameraState { get }
    var hasPermission: Bool { get }

    func requestPermissionAndStart() async
    func stopSession() async
    func capturePhoto() async
}

protocol PlantDatabaseServiceProtocol: AnyObject {
    var savedPlants: [PlantIdentity] { get }

    func savePlant(_ plant: PlantIdentity) async throws
    func deletePlant(_ id: UUID) async throws
}