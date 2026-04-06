// BEFORE: Custom enum (wrong API)
enum TransactionState {
    case verified
    case unverified
    case revoked
}

// AFTER: Use StoreKit 2 proper types

enum StoreEnvironment {
    case production
    case sandbox
}