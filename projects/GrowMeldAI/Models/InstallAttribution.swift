// Models/Attribution.swift
import Foundation

struct InstallAttribution: Codable {
    let source: InstallSource
    let campaignID: String?             // If from ASA
    let utmSource: String?
    let utmMedium: String?
    let utmCampaign: String?
    let timestamp: Date
}

enum InstallSource: String, Codable {
    case organic
    case appStore
    case asa                            // Apple Search Ads
    case unknown
}