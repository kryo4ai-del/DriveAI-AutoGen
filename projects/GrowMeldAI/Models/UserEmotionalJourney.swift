import Foundation

enum UserEmotionalJourney: String, CaseIterable {
    case fear = "Angst vor der Prüfung"
    case uncertainty = "Unsicherheit bei Fragen"
    case confidence = "Vertrauen in die Vorbereitung"
    case success = "Erfolgserlebnis"

    var messagingAnchor: String {
        switch self {
        case .fear:
            return "Bereite dich sicher auf die Prüfung vor"
        case .uncertainty:
            return "Verstehe jede Frage mit klaren Erklärungen"
        case .confidence:
            return "Übe mit echten Prüfungsfragen"
        case .success:
            return "Bestehe deine Theorieprüfung"
        }
    }
}

struct RegionalASOStrategy: Codable, Identifiable {
    let id: String
    let region: String
    let localizedName: String
    let localizedSubtitle: String
    let primaryKeywords: [String]
    let secondaryKeywords: [String]
    let pricingStrategy: PricingStrategy
    let legalDisclaimer: String

    init(region: String,
         localizedName: String,
         localizedSubtitle: String,
         primaryKeywords: [String],
         secondaryKeywords: [String],
         pricingStrategy: PricingStrategy,
         legalDisclaimer: String) {
        self.id = region
        self.region = region
        self.localizedName = localizedName
        self.localizedSubtitle = localizedSubtitle
        self.primaryKeywords = primaryKeywords
        self.secondaryKeywords = secondaryKeywords
        self.pricingStrategy = pricingStrategy
        self.legalDisclaimer = legalDisclaimer
    }

    enum PricingStrategy: Codable {
        case free
        case freemium
        case premium(price: String)
    }
}

struct ASORiskAssessment: Codable {
    let riskId: String
    let description: String
    let severity: RiskSeverity
    let likelihood: RiskLikelihood
    let mitigationStrategy: String
    let owner: String
    let status: RiskStatus

    enum RiskSeverity: String, Codable {
        case low, medium, high, critical
    }

    enum RiskLikelihood: String, Codable {
        case unlikely, possible, likely, almostCertain
    }

    enum RiskStatus: String, Codable {
        case identified, mitigated, accepted, resolved
    }
}

enum ASOExecutionPhase: String, CaseIterable, Codable {
    case researchAndStrategy = "Research & Strategy"
    case contentCreation = "Content Creation"
    case legalCompliance = "Legal Compliance"
    case assetProduction = "Asset Production"
    case technicalSetup = "Technical Setup"
    case preSubmissionQA = "Pre-Submission QA"
    case postLaunchMonitoring = "Post-Launch Monitoring"

    var phaseNumber: Int {
        switch self {
        case .researchAndStrategy: return 1
        case .contentCreation: return 2
        case .legalCompliance: return 3
        case .assetProduction: return 4
        case .technicalSetup: return 5
        case .preSubmissionQA: return 6
        case .postLaunchMonitoring: return 7
        }
    }
}

enum ASOAgentRole: String, Codable, CaseIterable {
    case growthAgent = "Growth Agent"
    case productStrategist = "Product Strategist"
    case contentScript = "Content Script"
    case legalRisk = "Legal Risk"
    case iosDeveloper = "iOS Developer"
    case designer = "Designer"
    case qaLead = "QA Lead"
    case localizationAgent = "Localization Agent"
}

struct ASOAgentAssignment: Codable {
    let taskId: String
    let taskDescription: String
    let responsibleAgent: ASOAgentRole
    let secondaryAgents: [ASOAgentRole]
    let estimatedHours: Int
    let deadline: Date?
}