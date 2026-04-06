// Deliverable: Services/Location/LocationPermissionManager.swift
protocol LocationPermissionManager {
    var permissionStatus: LocationPermissionStatus { get }
    func requestPermission(for useCase: LocationDataModel.UseCase) async -> Bool
    func revokePermission(for useCase: LocationDataModel.UseCase) async
    func isConsented(for useCase: LocationDataModel.UseCase) -> Bool
}
