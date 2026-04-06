// Services/Protocols/CameraServiceProtocol.swift
protocol CameraServiceProtocol: AnyObject {
    var state: CameraState { get }
    var hasPermission: Bool { get }
    
    func requestPermissionAndStart() async
    func stopSession() async
    func capturePhoto() async
}

// Services/Protocols/VisionServiceProtocol.swift

// Services/Protocols/PlantDatabaseServiceProtocol.swift
protocol PlantDatabaseServiceProtocol: AnyObject {
    var savedPlants: [PlantIdentity] { get }
    
    func savePlant(_ plant: PlantIdentity) async throws
    func deletePlant(_ id: UUID) async throws
}