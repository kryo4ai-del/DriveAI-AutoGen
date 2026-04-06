// Models/SyncableData.swift
protocol SyncableEntity {
    var id: UUID { get }
    var lastModified: Date { get }
    var syncVersion: Int { get }
    var isSynced: Bool { get }
}

// Services/LocalDataService.swift