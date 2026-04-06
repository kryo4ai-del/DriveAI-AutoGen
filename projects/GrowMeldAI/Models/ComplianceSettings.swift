// Models/ComplianceSettings.swift

import Foundation

struct ComplianceSettings: Codable {
    var storeExamResults: Bool
    var offlineModeEnabled: Bool
    var analyticsEnabled: Bool
    var marketingEnabled: Bool
    var retentionDays: Int
    var lastExportDate: Date?
    
    init(
        storeExamResults: Bool = true,
        offlineModeEnabled: Bool = true,
        analyticsEnabled: Bool = false,
        marketingEnabled: Bool = false,
        retentionDays: Int = 90,
        lastExportDate: Date? = nil
    ) {
        self.storeExamResults = storeExamResults
        self.offlineModeEnabled = offlineModeEnabled
        self.analyticsEnabled = analyticsEnabled
        self.marketingEnabled = marketingEnabled
        self.retentionDays = retentionDays
        self.lastExportDate = lastExportDate
    }
}