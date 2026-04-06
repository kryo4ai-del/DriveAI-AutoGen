// CloudDataError.swift
import Foundation

enum CloudDataError: Error {
    case encodingFailed
    case encryptionFailed
    case decryptionFailed
    case networkError(Error)
    case userNotAuthenticated
}