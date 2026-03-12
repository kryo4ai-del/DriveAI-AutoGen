import Foundation
extension ScannedDocument {
       var formattedTimestamp: String {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .short
           return formatter.string(from: timestamp)
       }
   }