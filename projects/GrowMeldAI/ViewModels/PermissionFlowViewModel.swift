@MainActor
final class PermissionFlowViewModel: ObservableObject {
    @Published private(set) var state: PermissionFlowState = .initial
    
    private func transition(to next: PermissionFlowState) {
        withAnimation(.easeInOut(duration: 0.3)) {
            state = next
            updateProgress()
            announceStateChange()  // ✅ Add this
        }
    }
    
    private func announceStateChange() {
        let announcement: String
        
        switch state {
        case .requestingPermission:
            announcement = String(localized: "voiceover.state_requesting_permission", bundle: .module)
            // "Requesting camera permission. A system dialog will appear."
            
        case .permissionGranted:
            announcement = String(localized: "voiceover.state_permission_granted", bundle: .module)
            // "Permission granted. Ready to capture photo."
            
        case .capturingPhoto:
            announcement = String(localized: "voiceover.state_capturing", bundle: .module)
            // "Camera is now active. Position your ID in the center."
            
        case .photoReady:
            announcement = String(localized: "voiceover.state_photo_ready", bundle: .module)
            // "Photo captured. Preview screen shown. Tap to proceed."
            
        case .previewingPhoto:
            announcement = String(localized: "voiceover.state_previewing", bundle: .module)
            // "Reviewing photo. Confirm or retake."
            
        case .completed:
            announcement = String(localized: "voiceover.state_completed", bundle: .module)
            // "Onboarding complete. Proceeding to main app."
            
        case .error(let error):
            announcement = error.errorDescription ?? "An error occurred"
            
        default:
            announcement = ""
        }
        
        if !announcement.isEmpty {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}