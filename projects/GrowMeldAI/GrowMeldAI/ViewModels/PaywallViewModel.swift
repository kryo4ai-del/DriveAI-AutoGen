// ViewModels/PaywallViewModel.swift
import Foundation
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var availableProducts: [IAPProduct] = []
    @Published var selectedProductId: String?
    @Published var isPurchasing = false
    @Published var error: IAPError?
    @Published var daysUntilExpiration: Int?

    private let storeKitManager: StoreKitManager
    private let entitlementService: EntitlementService
    private var cancellables = Set<AnyCancellable>()

    var premiumBenefits: [PremiumBenefit] {
        [
            PremiumBenefit(
                icon: "chart.bar.fill",
                title: "Detaillierte Analysen",
                description: "Erhalte Einblicke in deine Stärken und Schwächen"
            ),
            PremiumBenefit(
                icon: "infinity",
                title: "Unbegrenzte Tests",
                description: "Übe so oft du möchtest"
            ),
            PremiumBenefit(
                icon: "lightbulb.fill",
                title: "Lernfortschritt",
                description: "Verfolge deinen Fortschritt über die Zeit"
            )
        ]
    }

    var purchaseButtonLabel: String {
        isPurchasing ? "Verarbeite..." : "Jetzt Premium freischalten"
    }

    init(storeKitManager: StoreKitManager = StoreKitManager.shared,
         entitlementService: EntitlementService = EntitlementService.shared) {
        self.storeKitManager = storeKitManager
        self.entitlementService = entitlementService
        setupObservers()
        loadProducts()
    }

    private func setupObservers() {
        entitlementService.$userEntitlements
            .compactMap { $0?.subscriptionStatus }
            .sink { [weak self] status in
                self?.updateDaysUntilExpiration(status)
            }
            .store(in: &cancellables)
    }

    private func updateDaysUntilExpiration(_ status: SubscriptionStatus) {
        switch status {
        case .active(let expiresAt, _):
            let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
            daysUntilExpiration = max(days, 0)
        default:
            daysUntilExpiration = nil
        }
    }

    private func loadProducts() {
        Task {
            do {
                availableProducts = try await storeKitManager.loadProducts(
                    identifiers: ["premium_monthly", "premium_yearly"]
                )
            } catch {
                self.error = .productLoadingFailed
            }
        }
    }

    func purchase() async {
        guard let productId = selectedProductId else {
            error = .noProductSelected
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            guard let product = availableProducts.first(where: { $0.id == productId }) else {
                error = .productNotFound
                return
            }

            let transaction = try await storeKitManager.purchase(product)
            try await entitlementService.syncEntitlements()

            // Auto-close after successful purchase
            // In real app, you might want to navigate to a success screen
        } catch {
            self.error = error as? IAPError ?? .purchaseFailed
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await storeKitManager.restorePurchases()
            try await entitlementService.syncEntitlements()
        } catch {
            self.error = error as? IAPError ?? .restoreFailed
        }
    }
}

struct PremiumBenefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}