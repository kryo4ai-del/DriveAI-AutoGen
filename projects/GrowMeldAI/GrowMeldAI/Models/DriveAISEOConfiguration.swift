// MARK: - DriveAISEOFoundation.swift
// Purpose: Centralized SEO optimization infrastructure for DriveAI iOS app
// Import: Foundation (infrastructure layer)
// Note: This is an infrastructure file, not a user-facing component

import Foundation

/// Core SEO optimization configuration for DriveAI iOS app
struct DriveAISEOConfiguration: Codable, Equatable {
    // App Store Connect metadata
    let appStoreKeywords: [String]
    let appStoreSubtitle: String
    let appStoreDescription: String
    let promotionalText: String

    // Universal Links configuration
    let universalLinkDomains: [String]
    let deepLinkRoutes: [DriveAIDeepLinkRoute]

    // Web SEO configuration
    let webSEOMetadata: DriveAIWebSEOMetadata

    // Localization settings
    let primaryLanguage: String
    let supportedLanguages: [String]

    // Analytics configuration
    let analyticsTrackingID: String
    let appStoreRankingTracking: Bool

    // Performance thresholds
    let minimumLighthouseScore: Int
    let maximumKeywordDifficulty: Int

    // Initializer with default values
    init(
        appStoreKeywords: [String] = [],
        appStoreSubtitle: String = "Führerschein Theorie Test – Bestehen garantiert",
        appStoreDescription: String = "Lerne für deinen Führerschein mit DriveAI. Über 1000 Fragen, Statistiken und personalisierte Lernpläne. Bestehe deine Theorieprüfung beim ersten Mal!",
        promotionalText: String = "Jetzt kostenlos herunterladen und sicher durch die Prüfung kommen!",
        universalLinkDomains: [String] = ["driveai.de"],
        deepLinkRoutes: [DriveAIDeepLinkRoute] = [],
        webSEOMetadata: DriveAIWebSEOMetadata = DriveAIWebSEOMetadata(),
        primaryLanguage: String = "de",
        supportedLanguages: [String] = ["de"],
        analyticsTrackingID: String = "",
        appStoreRankingTracking: Bool = true,
        minimumLighthouseScore: Int = 90,
        maximumKeywordDifficulty: Int = 70
    ) {
        self.appStoreKeywords = appStoreKeywords
        self.appStoreSubtitle = appStoreSubtitle
        self.appStoreDescription = appStoreDescription
        self.promotionalText = promotionalText
        self.universalLinkDomains = universalLinkDomains
        self.deepLinkRoutes = deepLinkRoutes
        self.webSEOMetadata = webSEOMetadata
        self.primaryLanguage = primaryLanguage
        self.supportedLanguages = supportedLanguages
        self.analyticsTrackingID = analyticsTrackingID
        self.appStoreRankingTracking = appStoreRankingTracking
        self.minimumLighthouseScore = minimumLighthouseScore
        self.maximumKeywordDifficulty = maximumKeywordDifficulty
    }
}

/// Deep link route configuration for DriveAI
struct DriveAIDeepLinkRoute: Codable, Equatable, Identifiable {
    let id = UUID()
    let path: String
    let targetView: String
    let parameters: [String]?
    let description: String

    init(
        path: String,
        targetView: String,
        parameters: [String]? = nil,
        description: String = ""
    ) {
        self.path = path
        self.targetView = targetView
        self.parameters = parameters
        self.description = description
    }
}

/// Web SEO metadata configuration
struct DriveAIWebSEOMetadata: Codable, Equatable {
    let siteName: String
    let titleTemplate: String
    let description: String
    let keywords: [String]
    let author: String
    let canonicalURL: String
    let openGraphType: String
    let twitterCard: String

    init(
        siteName: String = "DriveAI - Führerschein Theorie Test",
        titleTemplate: String = "%@ | DriveAI",
        description: String = "Lerne für deinen Führerschein mit DriveAI. Über 1000 Fragen, Statistiken und personalisierte Lernpläne.",
        keywords: [String] = ["Führerschein", "Theorie Test", "Fahrschule", "iTheorie", "Führerscheintest"],
        author: String = "DriveAI GmbH",
        canonicalURL: String = "https://driveai.de",
        openGraphType: String = "website",
        twitterCard: String = "summary_large_image"
    ) {
        self.siteName = siteName
        self.titleTemplate = titleTemplate
        self.description = description
        self.keywords = keywords
        self.author = author
        self.canonicalURL = canonicalURL
        self.openGraphType = openGraphType
        self.twitterCard = twitterCard
    }
}

/// SEO validation result
struct DriveAISEOValidationResult: Equatable {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    let score: Int

    init(isValid: Bool = true, errors: [String] = [], warnings: [String] = [], score: Int = 100) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
        self.score = score
    }
}

/// SEO optimization service protocol
protocol DriveAISEOServiceProtocol {
    func validateConfiguration(_ config: DriveAISEOConfiguration) async -> DriveAISEOValidationResult
    func generateAppStoreKeywords(from keywords: [String]) -> String
    func generateDeepLinkConfiguration() -> [DriveAIDeepLinkRoute]
    func generateWebSEOMetadata() -> DriveAIWebSEOMetadata
    func checkAppStoreSubmissionStatus() async -> Bool
    func checkDesignLockStatus() async -> Bool
}

/// Concrete implementation of SEO service
final class DriveAISEOService: DriveAISEOServiceProtocol {
    private let appStoreConnect: AppStoreConnectService
    private let designSystem: DesignSystemService
    private let analytics: AnalyticsService

    init(
        appStoreConnect: AppStoreConnectService = AppStoreConnectService(),
        designSystem: DesignSystemService = DesignSystemService(),
        analytics: AnalyticsService = AnalyticsService()
    ) {
        self.appStoreConnect = appStoreConnect
        self.designSystem = designSystem
        self.analytics = analytics
    }

    // MARK: - Validation

    func validateConfiguration(_ config: DriveAISEOConfiguration) async -> DriveAISEOValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        var score = 100

        // Validate keywords
        if config.appStoreKeywords.isEmpty {
            errors.append("No keywords provided for App Store optimization")
            score -= 20
        } else if config.appStoreKeywords.count > 100 {
            warnings.append("Too many keywords (max 100 recommended)")
            score -= 5
        }

        // Validate subtitle length
        if config.appStoreSubtitle.count > 30 {
            errors.append("App Store subtitle exceeds 30 characters")
            score -= 15
        }

        // Validate description length
        if config.appStoreDescription.count > 4000 {
            errors.append("App Store description exceeds 4000 characters")
            score -= 15
        }

        // Validate promotional text length
        if config.promotionalText.count > 170 {
            warnings.append("Promotional text exceeds 170 characters")
            score -= 5
        }

        // Validate deep links
        if config.deepLinkRoutes.isEmpty {
            warnings.append("No deep links configured")
        }

        // Validate Lighthouse score
        if config.minimumLighthouseScore < 80 {
            warnings.append("Minimum Lighthouse score too low for good SEO")
            score -= 10
        }

        return DriveAISEOValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            score: max(0, score)
        )
    }

    // MARK: - Keyword Generation

    func generateAppStoreKeywords(from keywords: [String]) -> String {
        // Filter and format keywords for App Store
        let filteredKeywords = keywords
            .filter { $0.count <= 30 }
            .prefix(100)
            .map { $0.lowercased() }
            .joined(separator: ",")

        return filteredKeywords
    }

    // MARK: - Deep Link Configuration

    func generateDeepLinkConfiguration() -> [DriveAIDeepLinkRoute] {
        [
            DriveAIDeepLinkRoute(
                path: "quiz/category/verkehrszeichen",
                targetView: "QuizCategoryView",
                description: "Traffic sign quiz category"
            ),
            DriveAIDepLinkRoute(
                path: "exam/simulate",
                targetView: "ExamSimulatorView",
                description: "Full exam simulation"
            ),
            DriveAIDeepLinkRoute(
                path: "results/:examId",
                targetView: "ExamResultsView",
                parameters: ["examId"],
                description: "Exam results with detailed analysis"
            ),
            DriveAIDeepLinkRoute(
                path: "learn/statistics",
                targetView: "LearningStatisticsView",
                description: "User progress and statistics"
            )
        ]
    }

    // MARK: - Web SEO Metadata

    func generateWebSEOMetadata() -> DriveAIWebSEOMetadata {
        DriveAIWebSEOMetadata(
            siteName: "DriveAI - Führerschein Theorie Test",
            titleTemplate: "%@ | DriveAI",
            description: "Lerne für deinen Führerschein mit DriveAI. Über 1000 Fragen, Statistiken und personalisierte Lernpläne. Bestehe deine Theorieprüfung beim ersten Mal!",
            keywords: ["Führerschein", "Theorie Test", "Fahrschule", "iTheorie", "Führerscheintest", "Fahrschulprüfung", "Theorieprüfung", "Führerschein App"],
            author: "DriveAI GmbH",
            canonicalURL: "https://driveai.de",
            openGraphType: "website",
            twitterCard: "summary_large_image"
        )
    }

    // MARK: - Status Checks

    func checkAppStoreSubmissionStatus() async -> Bool {
        // In production, this would call App Store Connect API
        // For now, return a mock value with fallback
        do {
            let status = try await appStoreConnect.getSubmissionStatus()
            return status == .approved
        } catch {
            // Fallback for development
            return ProcessInfo.processInfo.environment["APP_STORE_SUBMISSION"] == "approved"
        }
    }

    func checkDesignLockStatus() async -> Bool {
        // In production, this would check design system repository
        // For now, return a mock value with fallback
        do {
            let isLocked = try await designSystem.isDesignSystemLocked()
            return isLocked
        } catch {
            // Fallback for development
            return ProcessInfo.processInfo.environment["DESIGN_LOCKED"] == "true"
        }
    }
}

// MARK: - Service Interfaces (for dependency injection)

protocol AppStoreConnectServiceProtocol {
    func getSubmissionStatus() async throws -> AppStoreSubmissionStatus
}

enum AppStoreSubmissionStatus {
    case notSubmitted
    case inReview
    case approved
    case rejected
}

final class AppStoreConnectService: AppStoreConnectServiceProtocol {
    func getSubmissionStatus() async throws -> AppStoreSubmissionStatus {
        // In production: call App Store Connect API
        // For now, return mock value
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return .approved
    }
}

protocol DesignSystemServiceProtocol {
    func isDesignSystemLocked() async throws -> Bool
}

final class DesignSystemService: DesignSystemServiceProtocol {
    func isDesignSystemLocked() async throws -> Bool {
        // In production: check design system repository
        // For now, return mock value
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network delay
        return true
    }
}

// MARK: - Preview Provider (for development)

#if DEBUG
struct DriveAISEOFoundation_Previews: PreviewProvider {
    static var previews: some View {
        Text("DriveAI SEO Foundation")
            .padding()
    }
}
#endif