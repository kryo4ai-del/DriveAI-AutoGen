// Modules/Subscription/Services/ProrateCalculator.swift
import Foundation

final class ProrateCalculator {
    private let monthlyPrice: Decimal = 4.99
    private let yearlyPrice: Decimal = 49.99
    
    // Calculate credit when upgrading mid-month
    func calculateMonthlyToYearlyCredit(
        subscriptionStartDate: Date,
        currentDate: Date = Date()
    ) -> Decimal {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        let daysPassed = Calendar.current.dateComponents([.day], from: subscriptionStartDate, to: currentDate).day ?? 0
        let daysRemaining = max(0, daysInMonth - daysPassed)
        
        // Credit = (remaining days / days in month) × monthly price
        let credit = (Decimal(daysRemaining) / Decimal(daysInMonth)) * monthlyPrice
        return credit.rounded(toPlaces: 2)
    }
    
    // Edge case: Handle leap years, DST transitions
    func calculateMonthlyToYearlyCredit(
        subscriptionStartDate: Date,
        billingCycleEndDate: Date  // ← More accurate approach
    ) -> Decimal {
        let daysRemaining = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: billingCycleEndDate
        ).day ?? 0
        
        guard daysRemaining > 0 else { return 0 }
        
        // Use actual cycle length (28-31 days)
        let cycleDays = Calendar.current.dateComponents(
            [.day],
            from: subscriptionStartDate,
            to: billingCycleEndDate
        ).day ?? 30
        
        let credit = (Decimal(daysRemaining) / Decimal(cycleDays)) * monthlyPrice
        return credit.rounded(toPlaces: 2)
    }
}

// Extension for Decimal rounding
extension Decimal {
    func rounded(toPlaces places: Int) -> Decimal {
        let divisor = NSDecimalNumber(string: "1.\(String(repeating: "0", count: places))")
        return (self as NSDecimalNumber).rounding(accordingToBehavior: nil) as Decimal
    }
}