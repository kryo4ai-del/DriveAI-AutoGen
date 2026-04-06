struct PremiumFeatureLockView: View {
    let onDismiss: (DismissReason) -> Void
    
    enum DismissReason {
        case userTappedBackground
        case userTappedCancel
        case purchaseSucceeded
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: require explicit cancel
                    // Don't auto-dismiss on background tap
                    // onDismiss(.userTappedBackground)
                }
            
            // Content...
            
            Button(action: {
                onDismiss(.userTappedCancel)
            }) {
                Text(NSLocalizedString("common.cancel", comment: ""))
            }
        }
    }
}