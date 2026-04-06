// Sources/Models/Backup/BackupMetadata.swift
import Foundation

struct BackupMetadata: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let displayName: String
    let size: String
    let version: Int
    let isValid: Bool

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: timestamp)
    }
}