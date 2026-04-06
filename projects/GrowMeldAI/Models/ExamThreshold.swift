enum ExamThreshold {
    case germany  // 90% pass, 70% weak
    case austria  // 80% pass, 60% weak (hypothetical)
    
    var passScore: Double { /* ... */ }
    var weakCategoryThreshold: Double { /* ... */ }
}
