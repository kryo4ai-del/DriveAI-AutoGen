hasher.combine(error)
        }
    }
}

// MARK: - Sendable Conformance (if T is Sendable)

extension ViewState: Sendable where T: Sendable {}

// MARK: - Extensions for Common Operations

extension ViewState {
    /// Provide default value if not in success state
    func valueOrDefault(_ defaultValue: T) -> T {
        value ?? defaultValue
    }
    
    /// Get partial or complete value, or default
    func getOrDefault(_ defaultValue: T) -> T {
        partialOrCompleteValue ?? defaultValue
    }
    
    /// Execute closure on success state only
    func onSuccess(_ closure: (T) -> Void) {
        if case .success(let data) = self {
            closure(data)
        }
    }
    
    /// Execute closure on failure state only
    func onFailure(_ closure: (DriveAIError) -> Void) {
        if case .failure(let error) = self {
            closure(error)
        }
    }
    
    /// Execute closure on loading state
    func onLoading(_ closure: (Double?, T?) -> Void) {
        if case .loading(let progress, let partial) = self {
            closure(progress, partial)
        }
    }
    
    /// Check if state equals another without considering progress precision
    /// Useful for discrete progress levels (0, 1, 2) instead of continuous
    func progressLevelEquals(_ other: ViewState<T>, level: Int) -> Bool {
        switch (self, other) {
        case (.loading(let lhsProgress, let lhsPartial), .loading(let rhsProgress, let rhsPartial)):
            let lhsLevel = lhsProgress.map { Int($0 * Double(level)) } ?? 0
            let rhsLevel = rhsProgress.map { Int($0 * Double(level)) } ?? 0
            return lhsLevel == rhsLevel && lhsPartial == rhsPartial
        default:
            return self == other
        }
    }
}