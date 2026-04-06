// PrivacyPolicyView.swift
import SwiftUI

struct PrivacyPolicyView: View {
    let localizationService = LocalizationService.shared

    var body: some View {
        WebView(url: localizationService.getPrivacyPolicyURL())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}