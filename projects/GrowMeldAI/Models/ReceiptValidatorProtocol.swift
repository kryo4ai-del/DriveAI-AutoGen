// ReceiptValidator.swift
import Foundation
import StoreKit

protocol ReceiptValidatorProtocol {
    func loadReceiptData() async throws -> Data
    func validateLocalReceipt(_ receiptData: Data) -> Bool
    func validateReceipt(_ receiptData: Data) async throws -> Bool
}

final class ReceiptValidator: ReceiptValidatorProtocol {
    private let receiptURL: URL

    init(receiptURL: URL? = nil) {
        self.receiptURL = receiptURL ?? Bundle.main.appStoreReceiptURL ??
            URL(fileURLWithPath: "/dev/null")
    }

    func loadReceiptData() async throws -> Data {
        if FileManager.default.fileExists(atPath: receiptURL.path) {
            return try Data(contentsOf: receiptURL)
        }

        // Refresh receipt if missing
        try await refreshReceipt()
        return try Data(contentsOf: receiptURL)
    }

    func validateLocalReceipt(_ receiptData: Data) -> Bool {
        // Basic local validation
        return !receiptData.isEmpty
    }

    func validateReceipt(_ receiptData: Data) async throws -> Bool {
        // In production, this would call your server-side validation endpoint
        // For now, we'll simulate server validation
        #if DEBUG
        return true // Allow local testing
        #else
        // Simulate network call
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        return receiptData.count > 1000 // Arbitrary size check
        #endif
    }

    private func refreshReceipt() async throws {
        guard let windowScene = await UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            throw ReceiptError.noActiveScene
        }

        try await StoreKit.Transaction.refresh()
    }
}

enum ReceiptError: Error {
    case noActiveScene
    case receiptNotFound
    case validationFailed
}