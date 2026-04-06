// MARK: - Consolidated Mock Types
// File: Tests/Mocks/DriveAIMocks.swift
import Foundation
import StoreKit

// MARK: - Mock Products
struct MockProduct: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let price: Decimal
    let localizedPrice: String?
    let iconName: String?

    init(
        id: String,
        displayName: String,
        price: Decimal,
        localizedPrice: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.price = price
        self.localizedPrice = localizedPrice
        self.iconName = iconName
    }
}

// MARK: - Mock Transactions

// MARK: - Mock StoreKit Service