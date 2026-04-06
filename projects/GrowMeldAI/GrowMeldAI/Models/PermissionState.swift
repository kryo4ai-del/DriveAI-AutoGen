enum PermissionState {
    case accepted(date: Date)  // ✅ Has timestamp
    case denied(date: Date, nextRetryDate: Date?)
}

// ❌ But what was the content shown to the user?
// ❌ What language was it in?
// ❌ What was the exact value accepted?