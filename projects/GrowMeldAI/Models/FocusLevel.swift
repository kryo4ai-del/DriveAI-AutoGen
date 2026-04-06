The error "'FocusLevel' is ambiguous for type lookup in this context" suggests there's another `FocusLevel` type in the project conflicting with this one. The ambiguity occurs on line 52 inside the `init(normalised:)` method where `Self` is used. To fix this, we need to rename this type or fully qualify references. Since we can't change other files, the most likely issue is that the project has a naming conflict (possibly from a model or framework). A common fix is to disambiguate by using the module name or renaming. However, since we can only fix this file, let's try to resolve the ambiguity by being explicit and avoiding `Self` lookups that trigger the ambiguity:

```swift
import Foundation

enum FocusLevel: String, Codable, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case deep = "deep"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        case .deep:   return "Deep Focus"
        }
    }

    var score: Int {
        switch self {
        case .low:    return 1
        case .medium: return 2
        case .high:   return 3
        case .deep:   return 4
        }
    }

    var normalised: Double {
        Double(score) / Double(FocusLevel.allCases.count)
    }

    init?(score: Int) {
        switch score {
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        case 4: self = .deep
        default: return nil
        }
    }

    init(normalised value: Double) {
        let clamped = min(max(value, 0.0), 1.0)
        let count = FocusLevel.allCases.count
        let scoreValue = Int((clamped * Double(count - 1)).rounded()) + 1
        switch scoreValue {
        case 1: self = .low
        case 2: self = .medium
        case 3: self = .high
        case 4: self = .deep
        default: self = .medium
        }
    }
}

extension FocusLevel: Comparable {
    static func < (lhs: FocusLevel, rhs: FocusLevel) -> Bool {
        lhs.score < rhs.score
    }
}

extension FocusLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .low:
            return "Light engagement, easily distracted"
        case .medium:
            return "Moderate focus with occasional distractions"
        case .high:
            return "Strong concentration on the task"
        case .deep:
            return "Full immersion, maximum productivity"
        }
    }
}
```