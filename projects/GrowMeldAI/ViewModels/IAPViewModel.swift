// MARK: - ViewModels/IAPViewModel.swift

import SwiftUI
import Combine

@MainActor
final class IAPViewModel: ObservableObject {
  // MARK: - Published Properties
  @Published private(set) var products: [IAPProduct] = []
  @Published private(set) var isLoading = false
  @Published private(set) var error: IAPError?
  @Published private(set) var purchaseInProgress = false
  @Published private(set) var showPurchaseSuccess = false
  
  var entitlements: AnyPublisher<IAPEntitlements, Never> {
    iapService.entitlementsPublisher
  }
  
  // MARK: - State
  private let iapService: IAPServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  init(iapService: IAPServiceProtocol) {
    self.iapService = iapService
    loadProducts()
  }
  
  // MARK: - Public Methods
  
  func loadProducts() {
    isLoading = true
    error = nil
    
    Task {
      do {
        let loaded = try await iapService.loadProducts()
        self.products = loaded.sorted { product1, product2 in
          // Sort by cost per month
          let cost1 = costPerMonth(product1)
          let cost2 = costPerMonth(product2)
          return cost1 < cost2
        }
      } catch let iapError as IAPError {
        self.error = iapError
      } catch {
        self.error = .unknown(error.localizedDescription)
      }
      self.isLoading = false
    }
  }
  
  func purchase(_ product: IAPProduct) {
    purchaseInProgress = true
    error = nil
    
    Task {
      do {
        try await iapService.purchase(product: product)
        showPurchaseSuccess = true
        
        // Dismiss after 2 seconds
        try await Task.sleep(nanoseconds: 2_000_000_000)
        showPurchaseSuccess = false
      } catch let iapError as IAPError {
        self.error = iapError
      } catch {
        self.error = .unknown(error.localizedDescription)
      }
      purchaseInProgress = false
    }
  }
  
  func retryPurchase(_ product: IAPProduct) {
    purchase(product)
  }
  
  func dismissError() {
    error = nil
  }
  
  // MARK: - Computed Properties
  
  var recommendedProduct: IAPProduct? {
    products.sorted { product1, product2 in
      costPerMonth(product1) < costPerMonth(product2)
    }.first
  }
  
  func priceString(for product: IAPProduct) -> String {
    product.displayPrice
  }
  
  func billingPeriodString(for product: IAPProduct) -> String {
    guard let subscription = product.subscription else {
      return "Einmalig"
    }
    
    let period = subscription.period
    switch period.unit {
    case .day:
      return "pro Tag"
    case .week:
      return "pro Woche"
    case .month:
      return "pro Monat"
    case .year:
      return "pro Jahr"
    }
  }
  
  func accessibilityLabel(for product: IAPProduct) -> String {
    let price = product.displayPrice
    let period = billingPeriodString(for: product)
    return "\(product.displayName), \(price) \(period)"
  }
  
  // MARK: - Private Helpers
  
  private func costPerMonth(_ product: IAPProduct) -> Decimal {
    guard let subscription = product.subscription else {
      return product.price
    }
    
    let monthsInPeriod: Decimal = {
      switch subscription.period.unit {
      case .day:
        return Decimal(subscription.period.value) / 30
      case .week:
        return Decimal(subscription.period.value) / 4
      case .month:
        return Decimal(subscription.period.value)
      case .year:
        return Decimal(subscription.period.value) * 12
      }
    }()
    
    return product.price / monthsInPeriod
  }
}