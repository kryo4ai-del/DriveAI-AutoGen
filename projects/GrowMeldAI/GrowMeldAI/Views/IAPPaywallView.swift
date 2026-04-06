import SwiftUI

struct IAPPaywallView: View {
    @StateObject var viewModel: IAPViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                productCards
                benefitsList
                purchaseButton
            }
            .padding()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK", role: .cancel) { viewModel.dismissError() }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Unknown error")
        }
        .sheet(isPresented: $viewModel.showPurchaseSuccess) {
            PurchaseSuccessView {
                dismiss()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Fahrschul-Paket")
                .font(.title.bold())

            Text("Dein Weg zum Führerschein – ohne Stress")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var productCards: some View {
        ForEach(viewModel.products) { product in
            ProductCardView(product: product) {
                viewModel.purchase(product)
            }
            .disabled(viewModel.purchaseInProgress)
        }
    }

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            benefitRow(icon: "checkmark.circle.fill", text: "Unbegrenzte Theorie-Tests")
            benefitRow(icon: "checkmark.circle.fill", text: "Offizielle Prüfungsfragen")
            benefitRow(icon: "checkmark.circle.fill", text: "Statistiken & Fortschritte")
            benefitRow(icon: "checkmark.circle.fill", text: "Familienfreigabe möglich")
        }
        .padding(.vertical)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
            Spacer()
        }
    }

    private var purchaseButton: some View {
        Button(action: {}) {
            Text("Jetzt freischalten")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.purchaseInProgress)
    }
}

struct ProductCardView: View {
    let product: IAPProduct
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.subscription?.period.localizedDescription ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.title3.bold())
            }

            if product.isRecommended {
                Text("Beste Wahl")
                    .font(.caption)
                    .padding(4)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            Button(action: action) {
                Text("Auswählen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

struct PurchaseSuccessView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Premium freigeschaltet!")
                .font(.title.bold())

            Text("Dein Führerschein ist jetzt in Reichweite!")
                .font(.headline)
                .multilineTextAlignment(.center)

            Button("Fertig", action: onComplete)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 300)
    }
}