// File: DriveAI/Models/TrademarkStatus.swift
import Foundation

/// Represents the status of a trademark search
enum TrademarkStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case cleared = "Cleared"
    case conflictFound = "Conflict Found"
    case requiresAction = "Requires Action"
}

/// Represents a trademark search result for a specific region
struct TrademarkSearchResult: Identifiable, Codable {
    let id = UUID()
    let region: String // e.g., "DE", "AT", "CH"
    let status: TrademarkStatus
    let similarMarks: [String]
    let notes: String?

    init(region: String, status: TrademarkStatus, similarMarks: [String] = [], notes: String? = nil) {
        self.region = region
        self.status = status
        self.similarMarks = similarMarks
        self.notes = notes
    }
}

/// Represents the overall trademark compliance status
struct TrademarkCompliance: Codable {
    var appName: String
    var searchDate: Date?
    var results: [TrademarkSearchResult]
    var domainAvailability: [String: Bool] // [domain: isAvailable]
    var overallStatus: TrademarkStatus {
        if results.contains(where: { $0.status == .conflictFound }) {
            return .conflictFound
        } else if results.contains(where: { $0.status == .requiresAction }) {
            return .requiresAction
        } else if results.allSatisfy({ $0.status == .cleared }) {
            return .cleared
        } else {
            return .inProgress
        }
    }

    init(appName: String = "DriveAI") {
        self.appName = appName
        self.results = [
            TrademarkSearchResult(region: "DE", status: .notStarted),
            TrademarkSearchResult(region: "AT", status: .notStarted),
            TrademarkSearchResult(region: "CH", status: .notStarted)
        ]
        self.domainAvailability = [
            "driveai.de": false,
            "driveai.at": false,
            "driveai.ch": false,
            "driveai.com": true
        ]
    }
}