// Domain/Freemium/Services/HapticFeedbackService.swift
public protocol HapticFeedback: Sendable {
    func trigger(style: UIImpactFeedbackStyle) async
}

public actor DefaultHapticFeedback: HapticFeedback {
    public func trigger(style: UIImpactFeedbackStyle) async {
        await MainActor.run {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

// Mock for testing
public actor MockHapticFeedback: HapticFeedback {
    public private(set) var triggeredStyles: [UIImpactFeedbackStyle] = []
    
    public func trigger(style: UIImpactFeedbackStyle) async {
        triggeredStyles.append(style)
    }
}

// In FreemiumService