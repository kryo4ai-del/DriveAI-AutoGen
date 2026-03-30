# DAI-Core Firebase Analytics — Integration Guide

> For the Assembly Agent: How to integrate Firebase Analytics into a DAI-Core iOS app.

---

## 1. Add Firebase SDK via SPM

In Xcode:

1. **File > Add Package Dependencies...**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select version rule: **Up to Next Major** (current: 11.x)
4. Add these products to your target:
   - `FirebaseAnalytics`
   - `FirebaseCrashlytics`

> Do NOT add other Firebase products unless the app specifically requires them.

---

## 2. GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing) for the app
3. Register the iOS app with the correct **Bundle ID**
4. Download `GoogleService-Info.plist`
5. Add it to the Xcode project root (ensure "Copy items if needed" is checked)
6. Verify it is included in the target's **Build Phases > Copy Bundle Resources**

A template file (`GoogleService-Info.plist.template`) is provided in this directory for reference. Replace all `{{PLACEHOLDER}}` values with actual Firebase project values.

---

## 3. Initialize in App Startup

### SwiftUI App

```swift
import SwiftUI

@main
struct MyApp: App {
    init() {
        AnalyticsManager.shared.configure()
        AnalyticsManager.shared.setAppProfile(profile: "utility") // or: gaming, education, content, subscription
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### UIKit AppDelegate

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    AnalyticsManager.shared.configure()
    AnalyticsManager.shared.setAppProfile(profile: "utility")
    return true
}
```

---

## 4. Auto-Tracked Standard Events

These events should be logged automatically by the app scaffold (no manual work needed if using DAI-Core templates):

| Event | When | Code |
|---|---|---|
| `dai_app_open` | App enters foreground | `AnalyticsManager.shared.log(.appOpen)` |
| `dai_app_background` | App enters background | `AnalyticsManager.shared.log(.appBackground)` |

Place these in `SceneDelegate` lifecycle methods or use SwiftUI's `@Environment(\.scenePhase)`:

```swift
.onChange(of: scenePhase) { _, newPhase in
    switch newPhase {
    case .active:
        AnalyticsManager.shared.log(.appOpen)
    case .background:
        AnalyticsManager.shared.log(.appBackground)
    default:
        break
    }
}
```

---

## 5. Onboarding Funnel

If the app has an onboarding flow, track it:

```swift
// User starts onboarding
AnalyticsManager.shared.log(.onboardingStart)

// Each step
AnalyticsManager.shared.log(.onboardingStep(step: 1, name: "welcome"))
AnalyticsManager.shared.log(.onboardingStep(step: 2, name: "permissions"))
AnalyticsManager.shared.log(.onboardingStep(step: 3, name: "profile_setup"))

// Completed or skipped
AnalyticsManager.shared.log(.onboardingComplete)
AnalyticsManager.shared.log(.onboardingSkip)
```

This creates a trackable funnel in Firebase Console under **Analytics > Funnels**.

---

## 6. Feature Usage

Track when users interact with key features:

```swift
// User used the feature
AnalyticsManager.shared.log(.featureUsed(name: "photo_editor"))

// User discovered a feature (e.g., tooltip shown)
AnalyticsManager.shared.log(.featureDiscovered(name: "dark_mode"))
```

---

## 7. Monetization Events

```swift
// Purchase flow started
AnalyticsManager.shared.log(.purchaseStart(productId: "com.app.premium_monthly"))

// Purchase completed
AnalyticsManager.shared.log(.purchaseComplete(
    productId: "com.app.premium_monthly",
    value: 9.99,
    currency: "USD"
))

// Subscription started
AnalyticsManager.shared.log(.subscriptionStart(planId: "premium_annual"))

// Ad shown
AnalyticsManager.shared.log(.adImpression(adType: "interstitial"))
```

---

## 8. Error Tracking

Log non-fatal errors for monitoring:

```swift
AnalyticsManager.shared.log(.errorOccurred(
    domain: "NetworkService",
    code: 503,
    description: "Server temporarily unavailable"
))
```

> Fatal crashes are captured automatically by Firebase Crashlytics.

---

## 9. Adding Custom App-Specific Events

For events not covered by `DAIAnalyticsEvent`, use `logEvent` directly:

```swift
AnalyticsManager.shared.logEvent(name: "recipe_saved", parameters: [
    "recipe_id": "abc123",
    "category": "dessert"
])
```

The `dai_` prefix is added automatically.

---

## 10. Screen View Tracking

Track screen views for navigation analytics:

```swift
AnalyticsManager.shared.logScreenView(screenName: "Settings")
```

For SwiftUI, use `.onAppear`:

```swift
SomeView()
    .onAppear {
        AnalyticsManager.shared.logScreenView(screenName: "SomeView")
    }
```

---

## 11. Conversion Tracking

Track key conversion events:

```swift
AnalyticsManager.shared.logConversion(type: "signup_complete")
AnalyticsManager.shared.logConversion(type: "first_purchase", value: 4.99, currency: "EUR")
```

---

## Files in This Template

| File | Purpose |
|---|---|
| `AnalyticsManager.swift` | Singleton manager — Firebase init + all logging methods |
| `AnalyticsEvents.swift` | Enum of standard DAI events with names and parameters |
| `GoogleService-Info.plist.template` | Placeholder plist — replace with real Firebase config |
| `INTEGRATION_GUIDE.md` | This file |

---

## Checklist for Assembly Agent

- [ ] Add `firebase-ios-sdk` via SPM (Analytics + Crashlytics)
- [ ] Download and add `GoogleService-Info.plist` from Firebase Console
- [ ] Copy `AnalyticsManager.swift` and `AnalyticsEvents.swift` into the project
- [ ] Call `AnalyticsManager.shared.configure()` in App init
- [ ] Set app profile via `setAppProfile(profile:)`
- [ ] Wire up `appOpen` / `appBackground` lifecycle events
- [ ] Add onboarding funnel tracking (if applicable)
- [ ] Add monetization events (if applicable)
- [ ] Verify events appear in Firebase Console DebugView
