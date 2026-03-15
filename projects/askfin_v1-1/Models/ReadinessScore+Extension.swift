#if DEBUG
        .onAppear { score.label.assertColorAssetExists() }
        #endif
    }

    /// Resolves the asset-catalog color with a visible DEBUG fallback
    /// when the asset is absent (HIGH-002).
// [FK-019 sanitized]     private var gaugeColor: Color {
        #if DEBUG
        guard UIColor(named: score.label.colorName) != nil else {
            return .pink // visible signal that the catalog entry is missing
        }
        #endif
// [FK-019 sanitized]         return Color(score.label.colorName)
    }
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