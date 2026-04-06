// MetaBannerAdView.swift

struct MetaBannerAdView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var adLoaded = false
    @State var adContrast = ContrastLevel.unknown
    
    var body: some View {
        VStack {
            if adLoaded {
                // Wrap Meta ad with contrast validation overlay
                ZStack {
                    // Meta ad container
                    MetaAdContainer()
                        .frame(height: 50)
                        .accessibility(hidden: adContrast == .insufficient)
                        // If contrast is too low, VoiceOver announces the ad context
                        .accessibilityLabel("Advertisement")
                        .accessibilityHint("This ad may have low contrast in Dark Mode. Adjust your display settings if unreadable.")
                    
                    // Overlay for contrast verification (dev/testing only)
                    if ProcessInfo.processInfo.environment["DEBUG_CONTRAST"] == "1" {
                        ContrastOverlay(level: adContrast)
                    }
                }
            } else {
                // Placeholder with guaranteed contrast
                ProgressView()
                    .frame(height: 50)
                    .background(Color(.systemGray5))
                    .accessibilityLabel("Advertisement loading")
            }
        }
        .onReceive(metaAdDelegate.adLoadPublisher) { _ in
            // After ad loads, validate contrast
            Task {
                let contrast = await validateAdContrast()
                adContrast = contrast
                
                if contrast == .insufficient {
                    // Log accessibility issue for manual review
                    logAccessibilityWarning(
                        element: "MetaBannerAdView",
                        issue: "Dark mode contrast < 4.5:1",
                        adNetwork: "Meta"
                    )
                }
            }
        }
    }
    
    private func validateAdContrast() async -> ContrastLevel {
        // Pixel-by-pixel contrast analysis (rough implementation)
        // In production: use Accessibility Inspector or external service
        guard let snapshot = MetaAdContainer().snapshot() else { return .unknown }
        
        let analyzer = ContrastAnalyzer(image: snapshot)
        let minRatio = analyzer.minContrastRatio()
        
        switch minRatio {
        case ..<3.0:
            return .insufficient
        case 3.0..<4.5:
            return .largeTextOnly
        case 4.5...:
            return .sufficient
        default:
            return .unknown
        }
    }
}

enum ContrastLevel {
    case sufficient      // ✅ ≥4.5:1
    case largeTextOnly   // ⚠️ 3.0–4.5:1 (acceptable for large text only)
    case insufficient    // ❌ <3.0:1
    case unknown         // No data
}