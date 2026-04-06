// Use actual PLZ mapping data from official German Post source
// Example: store as JSON file, not hardcoded
struct PLZRangeData: Codable {
    let bundesland: String
    let id: String
    let ranges: [PLZRange]  // Multiple ranges per state
}

struct PLZRange: Codable {
    let start: String  // "01000"
    let end: String    // "02999"
}

// Load from Bundle:
// let ranges = try JSONDecoder().decode([PLZRangeData].self, from: bundleData)