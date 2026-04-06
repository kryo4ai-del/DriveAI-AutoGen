// Domain/Freemium/Utilities/FreemiumDateFormatter.swift
enum FreemiumDateFormatter {
    private static let iso8601 = ISO8601DateFormatter()
    
    static func string(from date: Date) -> String {
        iso8601.string(from: date)
    }
    
    static func date(from string: String) -> Date? {
        iso8601.date(from: string)
    }
}

// Then in TrialPeriod.swift
struct TrialPeriod: Codable {
    var startDate: Date

    enum CodingKeys: String, CodingKey {
        case startDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            FreemiumDateFormatter.string(from: startDate),
            forKey: .startDate
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startStr = try container.decode(String.self, forKey: .startDate)
        guard let start = FreemiumDateFormatter.date(from: startStr) else {
            throw FreemiumError.dateCalculationFailed
        }
        self.startDate = start
    }
}

enum FreemiumError: Error {
    case dateCalculationFailed
}