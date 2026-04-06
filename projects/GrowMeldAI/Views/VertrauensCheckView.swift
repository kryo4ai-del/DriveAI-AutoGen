import SwiftUI

struct VertrauensCheckView: View {
    @StateObject private var consentManager: MetaAdsConsentManager
    @State private var userMadeChoice = false
    @State private var selectedConsent: Bool?
    @FocusState private var focusedField: FocusField?

    enum FocusField: Hashable {
        case toggle
        case continueButton
    }

    init(consentManager: MetaAdsConsentManager = .init()) {
        _consentManager = StateObject(wrappedValue: consentManager)
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("Deine Daten bleiben sicher")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Wir bauen Vertrauen auf, nicht Werbung. Deine Daten helfen uns nur, dir bessere Lerninhalte zu zeigen – ohne Tracking.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Toggle("Meta Werbung unterstützen", isOn: Binding(
                get: { consentManager.consentState == .granted },
                set: { newValue in
                    selectedConsent = newValue
                    userMadeChoice = true
                }
            ))
            .focused($focusedField, equals: .toggle)
            .padding(.horizontal)

            if userMadeChoice {
                Button(action: proceedToNextStep) {
                    Text("Weiter")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .focused($focusedField, equals: .continueButton)
                .padding(.horizontal)
            } else {
                Button("Weiter") {
                    focusedField = .continueButton
                }
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .padding(.horizontal)
                .disabled(true)
                .opacity(0.5)
            }

            Spacer()
        }
        .navigationTitle("Datenschutz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedField = .toggle
        }
    }

    private func proceedToNextStep() {
        guard let selectedConsent else { return }

        let newState = selectedConsent ? ConsentState.granted : ConsentState.denied
        consentManager.saveConsentState(newState)

        // Request ATT if needed
        if consentManager.attStatus == .notDetermined {
            Task {
                await requestATT()
            }
        }
    }

    private func requestATT() async {
        // In production, this would use ATTrackingManager.requestTrackingAuthorization
        try? await Task.sleep(nanoseconds: 500_000_000)
        consentManager.saveATTStatus(.authorized)
    }
}