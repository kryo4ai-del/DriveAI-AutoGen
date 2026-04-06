struct MaintenanceCheckPayload: Codable {
    let type: MaintenanceCheckType
    let severity: CheckSeverity
    let metadata: AnyCodable?  // Use library like AnyCodable from Swift
}