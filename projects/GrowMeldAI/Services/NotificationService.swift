// Add to Xcode Build Settings (Phase 1 default)
// Swift Compiler - Custom Flags: -DPHASE_2_APPROVED=0

// NotificationService.swift
#if PHASE_2_APPROVED
import FirebaseMessaging

// Class NotificationService declared in Services/NotificationService.swift
#else
class NotificationService {
    static let shared = NotificationService()
    
    func registerForRemoteNotifications() {
        fatalError("🚫 Push notifications unavailable until Phase 2 legal clearance. Current: PHASE_2_APPROVED=0")
    }
}
#endif