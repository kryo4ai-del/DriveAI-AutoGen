import Foundation

public struct Variant: Identifiable, Codable {
    public let id: String
    public let experimentID: String
    public let name: String
    public let description: String?
    public let allocationPercentage: Double
    public let configuration: VariantConfiguration
    public var metadata: [String: String]
    
    public init(
        id: String = UUID().uuidString,
        experimentID: String,
        name: String,
        description: String? = nil,
        allocationPercentage: Double,
        configuration: VariantConfiguration,
        metadata: [String: String] = [:]
    ) throws {
        guard allocationPercentage > 0 && allocationPercentage <= 100 else {
            throw DomainError.invalidVariant(
                reason: "Allocation must be 0 < x ≤ 100, got \(allocationPercentage)"
            )
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw DomainError.invalidVariant(reason: "Variant name cannot be empty")
        }
        
        self.id = id
        self.experimentID = experimentID
        self.name = trimmedName
        self.description = description
        self.allocationPercentage = allocationPercentage
        self.configuration = configuration
        self.metadata = metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let experimentID = try container.decode(String.self, forKey: .experimentID)
        let name = try container.decode(String.self, forKey: .name)
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        let allocation = try container.decode(Double.self, forKey: .allocationPercentage)
        let configuration = try container.decode(VariantConfiguration.self, forKey: .configuration)
        let metadata = try container.decode([String: String].self, forKey: .metadata)
        
        try self.init(
            id: id,
            experimentID: experimentID,
            name: name,
            description: description,
            allocationPercentage: allocation,
            configuration: configuration,
            metadata: metadata
        )
    }
}

public struct VariantConfiguration: Codable {
    public enum AnswerLayout: String, Codable {
        case vertical
        case horizontal
        case grid
    }
    
    public enum TimerStyle: String, Codable {
        case countdown
        case progressBar
        case hidden
    }
    
    public enum FeedbackTiming: String, Codable {
        case immediate
        case afterAnswer
        case afterQuestion
    }
    
    public let answerLayout: AnswerLayout
    public let timerStyle: TimerStyle
    public let showHint: Bool
    public let showExplanation: Bool
    public let feedbackTiming: FeedbackTiming
    
    public init(
        answerLayout: AnswerLayout = .vertical,
        timerStyle: TimerStyle = .countdown,
        showHint: Bool = false,
        showExplanation: Bool = true,
        feedbackTiming: FeedbackTiming = .immediate
    ) {
        self.answerLayout = answerLayout
        self.timerStyle = timerStyle
        self.showHint = showHint
        self.showExplanation = showExplanation
        self.feedbackTiming = feedbackTiming
    }
}