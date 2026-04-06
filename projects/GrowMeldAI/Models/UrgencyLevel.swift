enum UrgencyLevel: Comparable {
    case critical, urgent, soon, upcoming, scheduled
    
    var priority: Int {
        switch self {
        case .critical: return 5
        case .urgent: return 4
        case .soon: return 3
        case .upcoming: return 2
        case .scheduled: return 1
        }
    }
    
    static func < (lhs: UrgencyLevel, rhs: UrgencyLevel) -> Bool {
        lhs.priority < rhs.priority
    }
}