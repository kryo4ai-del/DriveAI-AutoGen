// File: Models/CloudFunctionError.swift (modification)
import Foundation

protocol AccessibleError: LocalizedError {
    var accessibilityMessage: String { get }
    var accessibilityAction: String? { get }
}
