enum CrashlyticsEnvironment {
    case development
    case staging
    case production
    
    static var current: CrashlyticsEnvironment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
}
