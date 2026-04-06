// Define timing constants
enum AnimationTiming {
    static let short: CGFloat = 0.15
    static let standard: CGFloat = 0.2
    static let long: CGFloat = 0.3
}

// Use consistently
withAnimation(.easeInOut(duration: AnimationTiming.standard)) {
    viewModel.selectCountry(country)
}