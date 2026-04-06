// DataDeletionError.swift
import Foundation

enum DataDeletionError: Error {
    case authDeletionFailed
    case firestoreDeletionFailed
    case fcmTokenDeletionFailed
    case localDeletionFailed
}