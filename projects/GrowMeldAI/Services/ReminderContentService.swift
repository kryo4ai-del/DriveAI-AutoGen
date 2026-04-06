import Foundation

/// Generates localized, accessible notification content.
/// Ensures messages are motivational, clear, and VoiceOver-friendly.
final class ReminderContentService {
    // MARK: - Constants
    
    private enum Constants {
        static let maxBodyLength = 95
        static let truncationSuffix = "…"
    }
    
    // MARK: - Content Generation
    
    /// Generate notification body with dynamic motivational messaging
    /// - Parameters:
    ///   - readinessPercent: Exam readiness (0-100)
    ///   - weakestCategory: Category to focus on
    ///   - daysUntilExam: Days remaining (optional)
    /// - Returns: Localized, truncated notification body
    func generateNotificationBody(
        readinessPercent: Int,
        weakestCategory: String,
        daysUntilExam: Int? = nil
    ) -> String {
        let clamped = clamp(readinessPercent, min: 0, max: 100)
        
        let baseMessage: String
        if clamped >= 80 {
            baseMessage = "Großartig! Du bist fast fertig. Lerne noch \(weakestCategory)."
        } else if clamped >= 60 {
            baseMessage = "Guter Fortschritt! Festige dein Wissen in \(weakestCategory)."
        } else if clamped >= 40 {
            baseMessage = "Du machst Fortschritt! Fokussiere auf \(weakestCategory)."
        } else {
            baseMessage = "Beginne mit \(weakestCategory) – jede Lerneinheit zählt!"
        }
        
        return truncateIfNeeded(baseMessage)
    }
    
    /// Generate VoiceOver-friendly accessibility label
    /// Spells out all numbers and categories for clarity
    /// - Parameters:
    ///   - readinessPercent: Exam readiness (0-100)
    ///   - weakestCategory: Category to focus on
    ///   - daysUntilExam: Days remaining (optional)
    /// - Returns: Full accessibility announcement
    func generateAccessibilityLabel(
        readinessPercent: Int,
        weakestCategory: String,
        daysUntilExam: Int? = nil
    ) -> String {
        let clamped = clamp(readinessPercent, min: 0, max: 100)
        let percentText = germanNumber(clamped) + " Prozent"
        
        let baseLabel = "DriveAI Erinnerung. Du hast \(percentText) deiner Fahrprüfung beherrscht. Lerne jetzt \(weakestCategory)."
        
        if let days = daysUntilExam, days > 0 {
            let daysText = germanNumber(days)
            return baseLabel + " Noch \(daysText) Tage bis zur Prüfung."
        }
        
        return baseLabel
    }
    
    // MARK: - Private Helpers
    
    private func truncateIfNeeded(_ text: String) -> String {
        guard text.count > Constants.maxBodyLength else {
            return text
        }
        let truncated = String(text.prefix(Constants.maxBodyLength - 1))
        return truncated + Constants.truncationSuffix
    }
    
    private func clamp(_ value: Int, min minVal: Int, max maxVal: Int) -> Int {
        return Swift.max(minVal, Swift.min(maxVal, value))
    }
    
    /// Convert number to German text representation
    /// Handles 0-99, with fallback for larger numbers
    private func germanNumber(_ n: Int) -> String {
        let ones = [
            "null", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben",
            "acht", "neun"
        ]
        let teens = [
            "zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn",
            "sechzehn", "siebzehn", "achtzehn", "neunzehn"
        ]
        let tens = [
            "", "", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig",
            "siebzig", "achtzig", "neunzig"
        ]
        
        if n < 10 {
            return ones[n]
        } else if n < 20 {
            return teens[n - 10]
        } else if n < 100 {
            let tenDigit = n / 10
            let oneDigit = n % 10
            if oneDigit == 0 {
                return tens[tenDigit]
            }
            return ones[oneDigit] + "und" + tens[tenDigit]
        } else {
            return String(n)  // Fallback
        }
    }
}