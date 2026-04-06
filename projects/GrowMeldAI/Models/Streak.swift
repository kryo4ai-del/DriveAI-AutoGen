import Foundation
struct Streak: Codable {
       var current: Int = 0
       var longest: Int = 0
       var lastAnswerDate: Date?
       
       // Thread-safe increment (will use DispatchQueue in service)
       mutating func increment() {
           current += 1
           longest = max(longest, current)
           lastAnswerDate = Date()
       }
       
       mutating func reset() {
           current = 0
           lastAnswerDate = nil
       }
   }