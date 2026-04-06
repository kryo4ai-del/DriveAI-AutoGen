// ❌ AVOID: Retain cycles in closure-based delegates
weak var delegate: CameraDelegate?
imageProcessor.onComplete = { [weak self] in  // ⚠️ Dangerous
    self?.updateUI()
}

// ✅ PREFER: Protocol-based weak references
protocol CameraDelegate: AnyObject { }
weak var delegate: CameraDelegate?

// ✅ PREFER: Weak capture in ViewModels
@MainActor