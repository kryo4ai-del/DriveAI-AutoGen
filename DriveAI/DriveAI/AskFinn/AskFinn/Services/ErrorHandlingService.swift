import SwiftUI
class ErrorHandlingService {
       enum AppError: Error {
           case networkError(String)
           case dataNotFound(String)
           case unknown

           var localizedDescription: String {
               switch self {
                   case .networkError(let message): return "Network Error: \(message)"
                   case .dataNotFound(let message): return "Data Error: \(message)"
                   case .unknown: return "An unknown error has occurred."
               }
           }
       }

       static func showAlert(error: AppError) -> Alert {
           Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
       }
   }