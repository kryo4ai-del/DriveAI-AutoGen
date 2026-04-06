enum StoreKitEnvironment {
    case sandbox
    case production
    
    static var current: StoreKitEnvironment {
        #if DEBUG
        return .sandbox
        #else
        return .production
        #endif
    }
}
