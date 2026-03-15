#if DEBUG
        .onAppear { score.label.assertColorAssetExists() }
        #endif
    }

    /// Resolves the asset-catalog color with a visible DEBUG fallback
    /// when the asset is absent (HIGH-002).
// [FK-019 sanitized]     private var gaugeColor: Color {
// [FK-019 sanitized]         #if DEBUG
// [FK-019 sanitized]         guard UIColor(named: score.label.colorName) != nil else {
// [FK-019 sanitized]             return .pink // visible signal that the catalog entry is missing
// [FK-019 sanitized]         }
// [FK-019 sanitized]         #endif
// [FK-019 sanitized]         return Color(score.label.colorName)
// [FK-019 sanitized]     }
}

#if DEBUG
private extension ReadinessScore.ReadinessLabel {
    func assertColorAssetExists() {
        assert(
            UIColor(named: colorName) != nil,
            "Missing color asset '\(colorName)' for label '\(rawValue)'. " +
            "Add it to Assets.xcassets."
        )
    }
}
#endif