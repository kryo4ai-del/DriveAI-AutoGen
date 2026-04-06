struct MilestoneInsight {
    let category: String
    let fromAccuracy: Double
    let toAccuracy: Double
    let questionsCorrectConsecutively: Int
    let keyConceptsMastered: [String]   // What did they learn?
    let confusionPointsOvercome: [String]  // What did they struggle with?
    let nextChallenge: String           // Where to apply this knowledge?
}

// Example output:
"""
🟢 Traffic Signs — Mastered!
You jumped from 45% → 75% in 8 attempts.
You now recognize: Priority signs, Prohibition signs, Mandatory action signs.
Your biggest breakthrough: Understanding when triangles = warning vs. circles = commands.

Next: Apply this to exam-style timed questions.
"""