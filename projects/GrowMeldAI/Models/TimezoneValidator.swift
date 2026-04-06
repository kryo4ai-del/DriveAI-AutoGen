// Validators/TimezoneValidator.swift
struct TimezoneValidator {
    static func isDifferentCalendarDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let comps1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let comps2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return comps1 != comps2
    }
}