import UIKit

/// Micro-interaction feedback when limits are approached
public enum LimitApproachLevel: Equatable, Sendable {
    case comfortable       // > 3 actions remaining
    case warning          // 2-3 actions remaining
    case critical         // 1 action remaining
    case exceeded         // Limit reached
    
    public var hapticStyle: UIImpactFeedbackStyle? {
        switch self {
        case .comfortable:
            return nil
        case .warning:
            return .light
        case .critical:
            return .medium
        case .exceeded:
            return .heavy
        }
    }
}

/// Rich feedback returned after recording an action
public struct LimitFeedback: Equatable, Sendable {
    public let allowed: Bool
    public let remaining: Int  // Always >= 0 (clamped)
    public let approachLevel: LimitApproachLevel
    public let shouldTriggerHaptic: Bool
    
    /// Trigger haptic feedback (safe to call from any thread)
    public func triggerHapticIfNeeded() {
        guard shouldTriggerHaptic, let style = approachLevel.hapticStyle else { return }
        
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    /// Designated initializer with validation and level determination
    public init(
        allowed: Bool,
        remaining: Int,
        shouldTriggerHaptic: Bool = true
    ) {
        self.allowed = allowed
        self.remaining = max(0, remaining)  // ✅ Clamp negative values
        self.shouldTriggerHaptic = shouldTriggerHaptic
        
        // ✅ Determine approach level based on safe remaining value
        if !allowed {
            self.approachLevel = .exceeded
        } else if self.remaining <= 1 {
            self.approachLevel = .critical
        } else if self.remaining <= 3 {
            self.approachLevel = .warning
        } else {
            self.approachLevel = .comfortable
        }
    }
}