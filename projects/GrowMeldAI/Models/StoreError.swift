// Services/StoreKitService.swift
import StoreKit
import Foundation

enum StoreError: LocalizedError, Sendable {
    case productNotFound
    case purchaseFailed(String)
    case networkError
    case invalidReceipt
    case userCancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Produkt nicht gefunden"
        case .purchaseFailed(let message): return "Kauf fehlgeschlagen: \(message)"
        case .networkError: return "Netzwerkfehler"
        case .invalidReceipt: return "Ungültige Quittung"
        case .userCancelled: return "Kauf abgebrochen"
        case .unknown: return "Unbekannter Fehler"
        }
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(self.price)"
    }
}

extension SKError {
    var storeError: StoreError {
        switch self.code {
        case .paymentCancelled: return .userCancelled
        case .paymentNotAllowed: return .purchaseFailed("Zahlungen nicht erlaubt")
        case .storeProductNotAvailable: return .productNotFound
        default: return .purchaseFailed(self.localizedDescription)
        }
    }
}