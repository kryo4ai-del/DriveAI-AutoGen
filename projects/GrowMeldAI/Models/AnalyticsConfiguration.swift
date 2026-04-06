// Services/Analytics/Core/AnalyticsConfiguration.swift

import Foundation

struct AnalyticsConfiguration {
    let maxParametersPerEvent: Int
    let maxStringValueLength: Int
    let maxNumberValue: Int
    let allowedEventNamePattern: NSRegularExpression
    
    static let `default` = AnalyticsConfiguration()
    
    init(
        maxParametersPerEvent: Int = 25,
        maxStringValueLength: Int = 100,
        maxNumberValue: Int = Int.max,
        allowedEventNamePattern: NSRegularExpression? = nil
    ) {
        self.maxParametersPerEvent = maxParametersPerEvent
        self.maxStringValueLength = maxStringValueLength
        self.maxNumberValue = maxNumberValue
        
        // Firebase event names: alphanumeric + underscore, max 40 chars
        let pattern = try? NSRegularExpression(
            pattern: "^[a-zA-Z0-9_]{1,40}$",
            options: []
        )
        self.allowedEventNamePattern = pattern ?? NSRegularExpression()
    }
    
    /// Validate and normalize event parameters per Firebase limits
    func validateAndNormalize(_ params: [String: Any]?) -> [String: Any]? {
        guard var params = params else { return nil }
        
        // Enforce parameter count limit
        if params.count > maxParametersPerEvent {
            params = Dictionary(params.prefix(maxParametersPerEvent))
        }
        
        // Normalize each value
        let normalized = params.compactMapValues { value -> Any? in
            normalizeValue(value)
        }
        
        return normalized.isEmpty ? nil : normalized
    }
    
    private func normalizeValue(_ value: Any) -> Any? {
        switch value {
        case let stringValue as String:
            // Truncate strings to max length
            return stringValue.count > maxStringValueLength
                ? String(stringValue.prefix(maxStringValueLength))
                : stringValue
            
        case let intValue as Int:
            return intValue > maxNumberValue ? maxNumberValue : intValue
            
        case let doubleValue as Double:
            // Firebase accepts NSNumber
            return NSNumber(value: doubleValue)
            
        case let boolValue as Bool:
            // Firebase accepts NSNumber for booleans
            return NSNumber(value: boolValue)
            
        case _ as NSNull:
            return nil  // Firebase drops null values
            
        default:
            // Fallback: convert to string if possible
            return String(describing: value)
        }
    }
    
    /// Validate event name matches Firebase requirements
    func isValidEventName(_ name: String) -> Bool {
        let range = NSRange(name.startIndex..<name.endIndex, in: name)
        return allowedEventNamePattern.firstMatch(in: name, options: [], range: range) != nil
    }
}