import Foundation

/// Configuration for daily learning reminders.
/// Encapsulates time, frequency, and enabled state.
struct ReminderConfiguration: Codable, Identifiable, Equatable {
    let id: UUID
    var isEnabled: Bool
    var scheduledTime: DateComponents
    var frequency: ReminderFrequency
    var lastFiredDate: Date?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        isEnabled: Bool = false,
        scheduledTime: DateComponents = DateComponents(hour: 9, minute: 0),
        frequency: ReminderFrequency = .daily,
        lastFiredDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.scheduledTime = scheduledTime
        self.frequency = frequency
        self.lastFiredDate = lastFiredDate
        self.createdAt = createdAt
    }
    
    /// Format time for UI display: "09:00"
    var formattedTime: String {
        let hour = String(format: "%02d", scheduledTime.hour ?? 0)
        let minute = String(format: "%02d", scheduledTime.minute ?? 0)
        return "\(hour):\(minute)"
    }
    
    /// Accessibility-friendly time format: "neun Uhr"
    var accessibilityTime: String {
        let hour = scheduledTime.hour ?? 0
        let minute = scheduledTime.minute ?? 0
        return "\(germanHourName(hour)) Uhr \(germanMinuteName(minute))"
    }
    
    private func germanHourName(_ h: Int) -> String {
        let names = [
            "Mitternacht", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben",
            "acht", "neun", "zehn", "elf", "Mittag", "dreizehn", "vierzehn",
            "fünfzehn", "sechzehn", "siebzehn", "achtzehn", "neunzehn", "zwanzig",
            "einundzwanzig", "zweiundzwanzig", "dreiundzwanzig"
        ]
        return h < names.count ? names[h] : String(h)
    }
    
    private func germanMinuteName(_ m: Int) -> String {
        switch m {
        case 0: return "null"
        case 15: return "Viertel"
        case 30: return "halb"
        case 45: return "Dreiviertel"
        default: return germanNumber(m)
        }
    }
    
    private func germanNumber(_ n: Int) -> String {
        let ones = ["", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun"]
        let teens = ["zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn", "sechzehn", "siebzehn", "achtzehn", "neunzehn"]
        let tens = ["", "", "zwanzig", "dreißig", "vierzig", "fünfzig", "sechzig", "siebzig", "achtzig", "neunzig"]
        
        if n < 10 { return ones[n] }
        if n < 20 { return teens[n - 10] }
        
        let tenDigit = n / 10
        let oneDigit = n % 10
        
        if oneDigit == 0 { return tens[tenDigit] }
        return ones[oneDigit] + "und" + tens[tenDigit]
    }
}