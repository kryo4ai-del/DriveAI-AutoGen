// File: Models/CloudFunctionError.swift (modification)

protocol AccessibleError: LocalizedError {
    var accessibilityMessage: String { get }
    var accessibilityAction: String? { get }
}
