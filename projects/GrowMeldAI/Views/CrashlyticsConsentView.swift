import SwiftUI
import Foundation

struct AnalyticsConsent: Codable {
    var crashlyticsEnabled: Bool = true

    static let userDefaultsKey = "analyticsConsent"

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        crashlyticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .crashlyticsEnabled) ?? true
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AnalyticsConsent.userDefaultsKey)
        }
    }

    static func load() -> AnalyticsConsent {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let consent = try? JSONDecoder().decode(AnalyticsConsent.self, from: data) else {
            return AnalyticsConsent()
        }
        return consent
    }
}

struct CrashlyticsConsentView: View {
    @Binding var consent: AnalyticsConsent
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                Text("Help improve your exam prep experience")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text("Crash reports help us make the app smoother for your theory exam prep. This helps reduce technical issues that could disrupt your study sessions.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            Toggle("Allow crash reports", isOn: $consent.crashlyticsEnabled)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

            Spacer()

            Button("Continue") {
                consent.save()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
        }
        .navigationTitle("Crash Reports")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CrashlyticsConsentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CrashlyticsConsentView(consent: .constant(AnalyticsConsent()))
        }
    }
}