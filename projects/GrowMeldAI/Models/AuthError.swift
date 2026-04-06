The error "invalid redeclaration of 'AuthError'" means there's another `AuthError` type already defined elsewhere in your project. The fix is to rename this one to avoid the conflict.

```swift
import Foundation

enum AppAuthError: LocalizedError {
    case invalidEmail
    case weakPassword(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address."
        case .weakPassword(let reason):
            return "Weak password: \(reason)"
        }
    }
}
```