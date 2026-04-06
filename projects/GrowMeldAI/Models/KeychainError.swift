import Foundation
import Security

/// Secure credential storage using iOS Keychain.
/// Handles encrypted persistence of authentication tokens and cached user data.
/// Uses `actor` for thread-safe concurrent access.