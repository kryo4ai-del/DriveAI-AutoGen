extension LearningGap {
    var spaceRepetitionMessage: String {
        if let daysSince = daysSinceReview {
            if daysSince < 1 {
                return "Gut! Nächste Wiederholung in 2 Tagen empfohlen."
            } else if daysSince <= daysUntilNextReview {
                let daysLeft = daysUntilNextReview - daysSince
                return "Wiederholung wird fällig in \(daysLeft) Tagen – setzt dein Wissen fest."
            } else {
                return "Wiederholung überfällig – schnell trainieren für maximalen Lerneffekt!"
            }
        }
        return "Erste Wiederholung: Trainiere heute noch, um die Info ins Langzeitgedächtnis zu bringen."
    }
}