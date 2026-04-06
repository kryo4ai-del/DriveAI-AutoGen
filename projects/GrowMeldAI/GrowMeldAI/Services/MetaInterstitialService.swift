// MetaInterstitialService.swift

class MetaInterstitialService {
    func showInterstitial(from viewController: UIViewController) {
        guard MetaAdsFeatureFlag.isEnabled else { return }
        
        // Load Meta interstitial
        let interstitial = FBInterstitialAd(placementID: "YOUR_PLACEMENT_ID")
        interstitial.load(withBidPayload: nil) { [weak self] success, error in
            guard success else { return }
            
            // Wrap Meta's UIViewController with accessibility enhancements
            let accessibleController = AccessibleInterstitialWrapper(
                metaInterstitial: interstitial,
                closeHandler: { [weak self] in
                    self?.dismissInterstitial()
                }
            )
            viewController.present(accessibleController, animated: true)
        }
    }
}

// Wrapper to enforce accessibility best practices
struct AccessibleInterstitialWrapper {
    let metaInterstitial: FBInterstitialAd
    let closeHandler: () -> Void
    
    func makeViewController() -> UIViewController {
        let vc = UIViewController()
        
        // 1. Add close button with proper accessibility
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.setTitle(" Close Ad", for: .normal) // Label in addition to image
        closeButton.addAction(UIAction { [weak vc] _ in
            vc?.dismiss(animated: true)
            closeHandler()
        }, for: .touchUpInside)
        
        // 2. Accessibility configuration
        closeButton.accessibilityLabel = "Close advertisement"
        closeButton.accessibilityHint = "Dismiss this ad and return to your exam results."
        
        // 3. Ensure button is first in focus order
        closeButton.accessibilityViewIsModal = true // VoiceOver stops at this element
        vc.view.accessibilityElements = [closeButton] // Explicit focus order
        
        // 4. Force close button to top-right (not hidden behind ad content)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 44), // Minimum touch target
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 5. Support hardware keyboard escape
        vc.view.addKeyCommand(UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(dismissViaKeyboard),
            attributes: [],
            alternateTitle: nil
        ))
        
        // 6. Present Meta ad content below button
        vc.view.addSubview(metaInterstitial.view ?? UIView())
        // ... layout constraints for ad content
        
        return vc
    }
    
    @objc func dismissViaKeyboard() {
        closeHandler()
    }
}

// SwiftUI wrapper (if using SwiftUI for the rest of the app)
struct MetaInterstitialPresentation: ViewModifier {
    @State var isPresented: Bool
    let onClose: () -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onClose) {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                        }
                        .accessibilityLabel("Close advertisement")
                        .accessibilityHint("Dismiss this ad and return to your exam results.")
                        .padding()
                    }
                    
                    // Meta ad container
                    MetaInterstitialView()
                    
                    Spacer()
                }
                .background(Color(.systemBackground))
                .accessibilityViewIsModal(true) // Block interaction with background
                .onKeyCommand(input: UIKeyCommand.inputEscape) {
                    isPresented = false
                }
            }
    }
}