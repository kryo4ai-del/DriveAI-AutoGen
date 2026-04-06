import SwiftUI
struct WCAGColorPalette {
    let primaryAction = Color(red: 0.0, green: 0.47, blue: 0.84)  // #0078D4
    // Claim: 7.2:1 contrast on white background
    // Reality: Unknown on iOS system backgrounds (which vary by iOS version)
}