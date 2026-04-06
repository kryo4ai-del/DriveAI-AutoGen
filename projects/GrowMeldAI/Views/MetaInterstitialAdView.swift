// MetaInterstitialAdView.swift
import SwiftUI
import WebKit

/// Memory-safe Meta interstitial ad view
struct MetaInterstitialAdView: UIViewRepresentable {
    @Binding var isPresented: Bool
    let placementId: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard isPresented else { return }

        let html = """
        <html>
            <body style="margin:0; padding:0;">
                <script>
                    window.onload = function() {
                        window.location.href = 'meta-ads://interstitial?placement=\(placementId)';
                    };
                </script>
            </body>
        </html>
        """

        uiView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MetaInterstitialAdView

        init(parent: MetaInterstitialAdView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString,
               url.contains("meta-ads://") {
                parent.isPresented = false
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}