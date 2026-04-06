// ❌ CURRENT
struct CategoryStrength {
    let accuracy: Double      // 0.68 - no label
    let masteryLevel: MasteryLevel  // .intermediate - enum, not accessible
    let questionCount: Int    // 42 - raw number
}

// ✅ NEEDED
struct CategoryStrength {
    // ... existing fields ...
    
    var accessibilityLabel: String {
        "\(category.name), \(masteryLevel.label), \(accuracyPercentage) Prozent"
    }
    
    var accessibilityHint: String {
        "Du hast \(questionCount) Fragen beantwortet. Dein Können: \(masteryLevel.label)."
    }
}