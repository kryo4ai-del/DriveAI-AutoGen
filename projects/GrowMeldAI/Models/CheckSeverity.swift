import Foundation

enum CheckSeverity: Int, Comparable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
    static func < (lhs: CheckSeverity, rhs: CheckSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
