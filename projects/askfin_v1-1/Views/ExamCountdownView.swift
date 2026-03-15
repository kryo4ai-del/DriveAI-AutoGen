struct ExamCountdownView: View {
    let countdown: DateComponentsValue
    
    var countdownString: String {
        // ✅ Create accessible countdown string
        var components: [String] = []
        
        if countdown.day > 0 {
            let dayFormat = String(
                localized: "\(countdown.day) day\(countdown.day == 1 ? "" : "s")",
                comment: "Countdown days"
            )
            components.append(dayFormat)
        }
        
        if countdown.hour > 0 {
            let hourFormat = String(
                localized: "\(countdown.hour) hour\(countdown.hour == 1 ? "" : "s")",
                comment: "Countdown hours"
            )
            components.append(hourFormat)
        }
        
        if countdown.minute > 0 {
            let minuteFormat = String(
                localized: "\(countdown.minute) minute\(countdown.minute == 1 ? "" : "s")",
                comment: "Countdown minutes"
            )
            components.append(minuteFormat)
        }
        
        return components.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exam Date Countdown")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            HStack(spacing: 16) {
                CountdownItemView(value: countdown.day, unit: "days")
                    .accessibilityHidden(true) // Hide individual items from a11y tree
                
                CountdownItemView(value: countdown.hour, unit: "hours")
                    .accessibilityHidden(true)
                
                CountdownItemView(value: countdown.minute, unit: "minutes")
                    .accessibilityHidden(true)
            }
            
            // ✅ Provide semantic alternative for screen readers
            Text(countdownString)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true) // Visual only, a11y handled by group label
        }
        // ✅ Semantic grouping
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Exam countdown"))
        .accessibilityValue(
            Text(String(
                localized: "Time remaining: \(countdownString)",
                comment: "Countdown accessibility value"
            ))
        )
        .accessibilityHint(Text(NSLocalizedString(
            "Days, hours, and minutes until your exam",
            comment: "Countdown hint"
        )))
    }
}

struct CountdownItemView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit() // ✅ Better readability
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        // ✅ Each item has semantic meaning
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(unit))
        .accessibilityValue(Text("\(value)"))
    }
}