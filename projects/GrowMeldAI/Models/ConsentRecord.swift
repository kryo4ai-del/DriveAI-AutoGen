import Foundation

struct ConsentRecord {
    let birthYear: Int
    let birthMonth: Int  // 1-12
    let birthDay: Int    // 1-31
    let recordedDate: Date
    let deviceHash: String

    init(
        birthYear: Int,
        birthMonth: Int,
        birthDay: Int,
        recordedDate: Date = Date(),
        deviceHash: String
    ) {
        self.birthYear = birthYear
        self.birthMonth = birthMonth
        self.birthDay = birthDay
        self.recordedDate = recordedDate
        self.deviceHash = deviceHash
    }

    func calculateAge(on date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.year, .month, .day], from: date)

        guard
            let todayYear = today.year,
            let todayMonth = today.month,
            let todayDay = today.day
        else {
            return 0
        }

        var age = todayYear - birthYear

        if todayMonth < birthMonth {
            age -= 1
        } else if todayMonth == birthMonth && todayDay < birthDay {
            age -= 1
        }

        return max(0, age)
    }
}