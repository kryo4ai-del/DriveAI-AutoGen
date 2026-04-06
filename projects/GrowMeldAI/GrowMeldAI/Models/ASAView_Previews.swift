// MARK: - ASA Preview Provider
import SwiftUI

struct ASAView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ASAView()
                .environmentObject(ASAService())
                .previewLayout(.sizeThatFits)

            ASAConsentView(isPresented: .constant(true))
                .environmentObject(ASAService())
                .previewLayout(.sizeThatFits)
        }
    }
}