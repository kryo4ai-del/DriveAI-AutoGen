// Services/SearchAds/SearchAdsConfig.swift

import Foundation

/// Search Ads campaign configuration with mandatory legal gates
struct SearchAdsConfig: Codable, Equatable {
    // MARK: - Campaign Identity
    let campaignId: String?
    let keywords: [String]
    let bidAmount: Int?
    let creativeVariants: [String: String]
    let targetRegions: [String]
    
    // MARK: - Activation & Control
    let isActive: Bool
    
    // MARK: - MANDATORY Legal Gates (non-optional)
    /// Date legal team approved this campaign (REQUIRED for activation)
    let legallyApprovedDate: Date
    
    /// Email of legal reviewer (audit trail; REQUIRED)
    let legalReviewerEmail: String
    
    /// Legal review notes (e.g., "Approved per LEGAL-004; no trademark bidding on TÜV, DEKRA")
    let legalReviewNotes: String
    
    // MARK: - Metadata
    let metadata: [String: String]?
    
    // MARK: - Computed Properties (Safety Checks)
    
    /// Campaign is ready to launch only if ALL legal gates are satisfied
    var isReadyToLaunch: Bool {
        // Gate 1: Campaign must be explicitly active
        guard isActive else { return false }
        
        // Gate 2: Must have at least one keyword
        guard !keywords.isEmpty else { return false }
        
        // Gate 3: Legal approval date must be in the past (not future)
        guard legallyApprovedDate <= Date() else { return false }
        
        // Gate 4: Legal reviewer email must be present
        guard !legalReviewerEmail.isEmpty else { return false }
        
        // Gate 5: Legal review notes must be present
        guard !legalReviewNotes.isEmpty else { return false }
        
        return true
    }
    
    /// Human-readable status for debugging
    var readinessStatus: String {
        var statuses: [String] = []
        
        if !isActive {
            statuses.append("❌ Campaign not marked active")
        }
        
        if keywords.isEmpty {
            statuses.append("❌ No keywords configured")
        }
        
        if legallyApprovedDate > Date() {
            statuses.append("❌ Approval date in future: \(ISO8601DateFormatter().string(from: legallyApprovedDate))")
        }
        
        if legalReviewerEmail.isEmpty {
            statuses.append("❌ No legal reviewer email")
        }
        
        if legalReviewNotes.isEmpty {
            statuses.append("❌ No legal review notes")
        }
        
        if isReadyToLaunch {
            statuses.append("✅ Ready to launch (approved by \(legalReviewerEmail))")
        }
        
        return statuses.isEmpty ? "⚠️ Unknown state" : statuses.joined(separator: "; ")
    }
    
    // MARK: - Factory
    
    /// Empty/default config (safe fallback; never approved)
    static let empty = SearchAdsConfig(
        campaignId: nil,
        keywords: [],
        bidAmount: nil,
        creativeVariants: [:],
        targetRegions: [],
        isActive: false,
        legallyApprovedDate: Date.distantFuture,  // Default: never approved
        legalReviewerEmail: "",
        legalReviewNotes: ""
    )
}

// MARK: - Codable Helpers (for RemoteConfig deserialization)

extension SearchAdsConfig {
    enum CodingKeys: String, CodingKey {
        case campaignId, keywords, bidAmount, creativeVariants
        case targetRegions, isActive, legallyApprovedDate
        case legalReviewerEmail, legalReviewNotes, metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        campaignId = try container.decodeIfPresent(String.self, forKey: .campaignId)
        keywords = try container.decode([String].self, forKey: .keywords)
        bidAmount = try container.decodeIfPresent(Int.self, forKey: .bidAmount)
        creativeVariants = try container.decode([String: String].self, forKey: .creativeVariants)
        targetRegions = try container.decode([String].self, forKey: .targetRegions)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // Decode approval date; default to distantFuture if missing
        if let dateString = try container.decodeIfPresent(String.self, forKey: .legallyApprovedDate),
           let date = ISO8601DateFormatter().date(from: dateString) {
            legallyApprovedDate = date
        } else {
            legallyApprovedDate = Date.distantFuture
        }
        
        legalReviewerEmail = try container.decodeIfPresent(String.self, forKey: .legalReviewerEmail) ?? ""
        legalReviewNotes = try container.decodeIfPresent(String.self, forKey: .legalReviewNotes) ?? ""
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
    }
}