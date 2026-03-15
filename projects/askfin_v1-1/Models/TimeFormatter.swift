// Utilities/TimeFormatting.swift
struct TimeFormatter {
    enum Style {
        case exact      // "7h 25min"
        case estimated  // "~45 min"
        case short      // "7h"
    }
    
    static func format(_ minutes: Int, style: Style = .exact) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        let formatted: String
        if hours > 0 {
            formatted = "\(hours)h \(mins)min"
        } else {
            formatted = "\(mins)min"
        }
        
        switch style {
        case .exact: return formatted
        case .estimated: return "~\(formatted)"
        case .short: return hours > 0 ? "\(hours)h" : formatted
        }
    }
}

// Usage
// [FK-019 sanitized] var timeInvestedFormatted: String {
// [FK-019 sanitized]     TimeFormatter.format(timeInvestedMinutes)
// [FK-019 sanitized] }

// [FK-019 sanitized] var timeEstimate: String {
// [FK-019 sanitized]     TimeFormatter.format(estimatedMinutes, style: .estimated)
// [FK-019 sanitized] }