The error "'FocusLevel' is ambiguous for type lookup in this context" suggests there's another `FocusLevel` type in the project conflicting with this one. The ambiguity occurs on line 52 where `Self` is used inside the `init(normalised:)` initializer. To fix this, we can qualify the type or restructure to avoid the ambiguity. Since we can't rename the other conflicting type, we should ensure our references are unambiguous by using explicit module-qualified names or restructuring the code.

Given that the file likely belongs to a specific module, and the conflict is probably with an Apple framework type or another definition in the project, the simplest fix is to avoid the failable initializer call that causes the lookup issue:

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
        Double(score) / Double(Self.allCases.count)
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
        let count = Self.allCases.count
        let score = Int((clamped * Double(count - 1)).rounded()) + 1
        switch score {
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